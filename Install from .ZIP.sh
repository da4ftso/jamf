#!/usr/bin/env bash
# Jamf-aware installer for Sourcetree .zip files placed in:
# /Library/Application Support/JAMF/Waiting Room/
# Usage: pass a filter string as Jamf parameter $4. If $4 is empty or "all",
# all .zip files will be processed. Otherwise only .zip files whose names
# contain the filter substring (case-insensitive) will be handled.

set -euo pipefail
IFS=$'\n\t'

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }

# Jamf passes parameters as $4, $5, ...
# Read the filter from $4. If empty or "all", process all zips.
filter="${4:-}"
# Trim surrounding whitespace (best-effort)
filter="$(printf '%s' "$filter" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

# Determine the user who invoked sudo, or fall back to logname/$(whoami)
currentUser="${SUDO_USER:-$(logname 2>/dev/null || whoami)}"

waiting_dir="/Library/Application Support/JAMF/Waiting Room"

# Enable nullglob so a missing glob expands to nothing
shopt -s nullglob

log "Filter parameter (\$4) = '${filter:-<empty>}'"

# Build list of zip files based on filter
zips=()
if [ -z "$filter" ] || [ "$filter" = "all" ]; then
  zips=( "$waiting_dir"/*.zip )
else
  # Use case-insensitive matching to find files that contain the filter substring
  shopt -s nocaseglob
  zips=( "$waiting_dir"/*"$filter"*.zip )
  shopt -u nocaseglob
fi

if (( ${#zips[@]} == 0 )); then
  log "No matching .zip files found in '$waiting_dir' for filter '${filter:-all}'. Exiting."
  exit 1
fi

tmpdir="$(mktemp -d /tmp/sourcetree.install.XXXXXX)"
cleanup() {
  rm -rf -- "$tmpdir"
}
trap cleanup EXIT

for zip in "${zips[@]}"; do
  log "Processing: $zip"
  if /usr/bin/unzip -q -o -- "$zip" -d "$tmpdir"; then
    log "Extracted: $zip -> $tmpdir"
    rm -f -- "$zip"
  else
    log "Failed to unzip $zip; skipping."
    continue
  fi
done

# Find .app bundles in staging area
mapfile -t apps < <(find "$tmpdir" -maxdepth 4 -type d -name "*.app" -print)

if (( ${#apps[@]} == 0 )); then
  log "No .app bundles found after extraction. Exiting."
  exit 2
fi

for app in "${apps[@]}"; do
  appname="$(basename "$app")"
  dest="/Applications/$appname"
  log "Installing '$appname' to '$dest'"

  if [ -e "$dest" ]; then
    log "Existing application found at $dest — removing (will replace)."
    rm -rf -- "$dest"
  fi

  # Use ditto to preserve metadata; --noqtn avoids applying quarantine xattr
  if /usr/bin/ditto -rsrc --noqtn "$app" "$dest"; then
    log "Copied $appname to /Applications"
  else
    log "Failed to copy $appname to /Applications"
    continue
  fi

  # Remove extended attributes (quarantine) to avoid App Translocation (best-effort)
  if command -v xattr >/dev/null 2>&1; then
    log "Removing extended attributes (quarantine) from $dest"
    xattr -rc -- "$dest" 2>/dev/null || true
    xattr -d com.apple.quarantine -- "$dest" 2>/dev/null || true
  fi

  # Set ownership and permissions to currentUser.
  log "Ssetting ownership to $currentUser"
  chown -R "$currentUser":"$currentUser" -- "$dest" || true
  
  chmod -R u+rwX,go+rX,go-w -- "$dest" || true

  log "Installed $appname successfully"
done

# log "All done."

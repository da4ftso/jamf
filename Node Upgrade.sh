#!/bin/bash
set -euo pipefail

# 1.1 260428 PWC
# better error handling

# current user
loggedInUser=$(/usr/bin/stat -f%Su "/dev/console") || {
  echo "Error: Could not determine logged-in user" >&2
  exit 1
}

id "$loggedInUser" &>/dev/null || {
  echo "Error: User '$loggedInUser' does not exist" >&2
  exit 1
}

# homedir
currentUserHome=$(dscl . read "/Users/$loggedInUser" NFSHomeDirectory 2>/dev/null | awk -F': ' '{print $2}') || {
  echo "Error: Could not determine home directory for user '$loggedInUser'" >&2
  exit 1
}

# brew prefix
architectureCheck=$(/usr/bin/uname -m)
if [ "$architectureCheck" = "arm64" ]; then
  brewPrefix="/opt/homebrew/bin"
else
  brewPrefix="/usr/local/bin"
fi

brewPath="$brewPrefix/brew"

# is Homebrew installed?
if [ ! -e "$brewPath" ]; then
  echo "Error: Homebrew not found at $brewPath" >&2
  exit 1
fi

# is node installed?
if ! sudo -u "$loggedInUser" "$brewPath" list --formula | grep -q '^node$'; then
  echo "Node.js is not installed via Homebrew"
  exit 0
fi

# current version
currentVersion=$(sudo -u "$loggedInUser" "$brewPath" info node | grep -oP 'node \K[0-9]+\.[0-9]+\.[0-9]+' | head -1) || {
  echo "Warning: Could not determine current Node.js version" >&2
  currentVersion="unknown"
}

# upgrade
echo "Upgrading Node.js from $currentVersion..."
sudo -u "$loggedInUser" "$brewPath" upgrade node || {
  echo "Error: Homebrew upgrade failed" >&2
  exit 1
}

# new version after upgrade
newVersion=$(sudo -u "$loggedInUser" "$brewPath" info node | grep -oP 'node \K[0-9]+\.[0-9]+\.[0-9]+' | head -1) || {
  echo "Warning: Could not determine new Node.js version" >&2
  newVersion="unknown"
}

echo "Node.js upgrade complete: $currentVersion → $newVersion"
exit 0

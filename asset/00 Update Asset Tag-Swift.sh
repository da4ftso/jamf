#!/bin/bash
set -euo pipefail

# 3.0 260730

# since we don't want to leave API creds on an endpoint,
# we're still going to rely on recon
#
# this prompts the user and writes to some temp files
#
# then script 02 passes the values from those files to
# jamf recon, then cleans them up

# osascript
#  prompt for username and assetTag and building in a single window

answers=$(/usr/bin/env ./asset/answers.swift)

if [[ "$answers" == "__CANCELED__" ]]; then
  echo "User canceled. No files written." >&2
  exit 0
fi

# $answers to separate variables
IFS=$'\t' read -r username assetTag building <<< "$answers"

# write temp files
printf '%s\n' "$username"  > "/tmp/.username.txt"
printf '%s\n' "$assetTag"  > "/tmp/.assetTag.txt"
printf '%s\n' "$building"  > "/tmp/.building.txt"

# single combined output left here, but faster to cat each tmpfile than awk for each field
# cat > "$tmpdir/asset_info.env" <<EOF
# username=$username
# assetTag=$assetTag
# building=$building
# EOF

# echo "Wrote temp files to: $tmpdir"
# echo " - /tmp/.username.txt"
# echo " - /tmp/.assetTag.txt"
# echo " - /tmp/.building.txt"
# echo " - /tmp/.asset_info.env"

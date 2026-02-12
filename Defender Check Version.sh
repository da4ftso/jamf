#!/usr/bin/env bash

# TO-DO: validate DNS and connectivity to those hosts

currentUser=$( /usr/bin/stat -f%Su "/dev/console" )
currentUserHome=$(/usr/bin/dscl . -read "/Users/$currentUser" NFSHomeDirectory | /usr/bin/awk ' { print $NF } ')


# File to store the last seen version
VERSION_FILE="$currentUserHome/.wdav_last_version"
UPDATE_URL="https://officecdnmac.microsoft.com/pr/4B2D7701-0A4F-49C8-B4CB-0C2D4043F51F/MacAutoupdate/0409WDAV00-chk.xml"
PKG_URL="https://officecdnmac.microsoft.com/pr/4B2D7701-0A4F-49C8-B4CB-0C2D4043F51F/MacAutoupdate/wdav-upgrade.pkg"

# Get the current version from the XML feed
current_version=$(curl -s "$UPDATE_URL" | awk '/Update/ { getline ; print }' | sed 's/[^0-9\.]//g')

if [ -z "$current_version" ]; then
    echo "Could not retrieve current version."
    exit 1
fi

echo "Current version: $current_version"

# Check if version file exists
if [ -f "$VERSION_FILE" ]; then
    last_version=$(cat "$VERSION_FILE")
    echo "Last known version: $last_version"

    if [ "$current_version" == "$last_version" ]; then
        echo "No update detected."
        exit 0
    fi
else
    echo "📂 No previous version stored."
fi

# If we reach here, the version is new
echo "New version detected: $current_version"

# Download and rename the package
echo "⬇Downloading new wdav-upgrade.pkg..."
curl -s -O "$PKG_URL"

# Rename it to include the version number
mv wdav-upgrade.pkg "wdav-upgrade-$current_version.pkg"
echo "Saved as: wdav-upgrade-$current_version.pkg"

# Update the stored version
echo "$current_version" > "$VERSION_FILE"
echo "📁 Updated version record."

#!/bin/bash

# based on the Defender Check Version, needs more descriptive name though

currentUser=$( /usr/bin/stat -f%Su "/dev/console" )
currentUserHome=$(/usr/bin/dscl . -read "/Users/$currentUser" NFSHomeDirectory | /usr/bin/awk ' { print $NF } ')


# File to store the last seen version
VERSION_FILE="$currentUserHome/.figma_last_version"
UPDATE_URL="https://desktop.figma.com/mac-universal/releases.xml"
PKG_URL=$(curl $UPDATE_URL | grep -o 'https://[^"]*\.pkg | head -n 1')

# Get the current version from the XML feed
current_version=$(curl -s "$UPDATE_URL" | sed -n 's/.*Figma-\([0-9.]*\)\.pkg.*/\1/p' | head -n 1)

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
    echo "No previous version stored."
fi

# If we reach here, the version is new
echo "New version detected: $current_version"

# Download and rename the package
echo "⬇Downloading new Figma.pkg..."
curl -s -O "$PKG_URL"

# Update the stored version
echo "$current_version" > "$VERSION_FILE"
echo "Updated version record."

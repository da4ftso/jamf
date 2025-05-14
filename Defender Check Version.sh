#!/bin/bash

# File to store the last seen version
VERSION_FILE="$HOME/.wdav_last_version"
UPDATE_URL="https://officecdnmac.microsoft.com/pr/4B2D7701-0A4F-49C8-B4CB-0C2D4043F51F/MacAutoupdate/0409WDAV00-chk.xml"

# Get the current version from the XML feed
current_version=$(curl -s "$UPDATE_URL" | grep -o 'Version="[0-9.]*"' | head -n 1 | sed 's/Version="\([0-9.]*\)"/\1/')

if [ -z "$current_version" ]; then
    echo "❌ Could not retrieve current version."
    exit 1
fi

echo "🔍 Current version: $current_version"

# Check if version file exists
if [ -f "$VERSION_FILE" ]; then
    last_version=$(cat "$VERSION_FILE")
    echo "📦 Last known version: $last_version"

    if [ "$current_version" == "$last_version" ]; then
        echo "✅ No update detected."
        exit 0
    fi
else
    echo "📂 No previous version stored."
fi

# If we reach here, the version is new
echo "🚨 New version detected: $current_version"

# 👉 Your custom action here
# For example: trigger a Jamf policy or download the new installer
echo "▶️ Running update process..."
curl -O https://officecdnmac.microsoft.com/pr/4B2D7701-0A4F-49C8-B4CB-0C2D4043F51F/MacAutoupdate/wdav-upgrade.pkg

# Update the stored version
echo "$current_version" > "$VERSION_FILE"
echo "📁 Updated version record."

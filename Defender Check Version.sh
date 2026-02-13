#!/usr/bin/env bash

# TO-DO: add quiet versus verbose modes

# variables
currentUser=$( /usr/bin/stat -f%Su "/dev/console" )
currentUserHome=$(/usr/bin/dscl . -read "/Users/$currentUser" NFSHomeDirectory | /usr/bin/awk ' { print $NF } ')

# local version store
VERSION_FILE="$currentUserHome/.wdav_last_version"
UPDATE_URL="https://officecdnmac.microsoft.com/pr/4B2D7701-0A4F-49C8-B4CB-0C2D4043F51F/MacAutoupdate/0409WDAV00-chk.xml"
PKG_URL="https://officecdnmac.microsoft.com/pr/4B2D7701-0A4F-49C8-B4CB-0C2D4043F51F/MacAutoupdate/wdav-upgrade.pkg"

# check DNS
check_dns_resolution() {
    local url="$1"
    local host
    host=$(echo "$url" | sed 's|https://||; s|http://||; s|/.*||')
    
    # echo "Checking DNS resolution for: $host"
    if /usr/bin/host "$host" > /dev/null 2>&1; then
        # echo "✓ DNS resolution successful for $host"
        return 0
    else
        echo "✗ DNS resolution failed for $host"
        return 1
    fi
}

# check connectivity
check_connectivity() {
    local url="$1"
    
    # echo "Checking connectivity to: $url"
    if curl -s --max-time 10 -I "$url" > /dev/null 2>&1; then
        # echo "✓ Connectivity successful to $url"
        return 0
    else
        echo "✗ Connectivity failed to $url"
        return 1
    fi
}

# validate
check_dns_resolution "$UPDATE_URL" || exit 1
check_dns_resolution "$PKG_URL" || exit 1

check_connectivity "$UPDATE_URL" || exit 1
check_connectivity "$PKG_URL" || exit 1

# current version from XML
current_version=$(curl -s "$UPDATE_URL" | awk '/Update/ { getline ; print }' | sed 's/[^0-9\.]//g')

if [ -z "$current_version" ]; then
    echo "Could not retrieve current version."
    exit 1
fi

echo "Current version: $current_version"

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

# new version detected
echo "New version detected: $current_version"

# download
echo "⬇ Downloading new wdav-upgrade.pkg..."
curl -s -O "$PKG_URL"

# rename to add version
mv wdav-upgrade.pkg "wdav-upgrade-$current_version.pkg"
echo "Saved as: wdav-upgrade-$current_version.pkg"

# Update the stored version
echo "$current_version" > "$VERSION_FILE"
echo "📁 Updated version record."
gn

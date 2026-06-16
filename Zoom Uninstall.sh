#!/bin/bash
set -euo pipefail

# user variables
lastUser=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }')
currentUser=$(/usr/bin/stat -f%Su "/dev/console")
userHome=$(/usr/bin/dscl . -read "/Users/$currentUser" NFSHomeDirectory | /usr/bin/awk '{ print $NF }')

if [[ -z "$currentUser" || "$currentUser" == "root" ]]; then
    userHome=$(/usr/bin/dscl . -read "/Users/$lastUser" NFSHomeDirectory | /usr/bin/awk '{ print $NF }')
fi

# bootout
PLIST="/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist"

if launchctl list | grep -iq "zoom"; then
    launchctl bootout system "$PLIST" || echo "Warning: Failed to bootout Zoom daemon"
fi

# remove files
declare -a FILES_TO_REMOVE=(
    "/Applications/zoom.us.app"
    "/Library/Application Support/zoom.us/"
    "/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist"
    "$userHome/Library/Caches/us.zoom.xos/"
    "$userHome/Library/HTTPStorages/us.zoom.xos/"
    "$userHome/Library/Logs/zoom.us/"
)

for item in "${FILES_TO_REMOVE[@]}"; do
    if [[ -e "$item" ]]; then
        if rm -rf "$item"; then
            echo "✓ Removed: $item"
        else
            echo "✗ Failed to remove: $item" >&2
        fi
    fi
done

# forget packages
for pkg in $(/usr/sbin/pkgutil --pkgs | grep -iE "zoom"); do
    if pkgutil --forget "$pkg"; then
        echo "✓ Forgot package: $pkg"
    else
        echo "✗ Failed to forget package: $pkg" >&2
    fi
done

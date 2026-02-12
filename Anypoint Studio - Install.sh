#!/usr/bin/env bash

# this assumes that you have cached an AnypointStudio.dmg to Waiting Room

# validation
if [[ -z "$4" ]]; then
    echo "Error: no filename provided, exiting.." >&2
    exit 1
fi

# variables
currentUser=$( stat -f%Su /dev/console )
DMG="$4"

# mount
hdiutil mount /Library/Application\ Support/JAMF/Waiting\ Room/"${DMG}"

# ditto doesn't seem to work reliably, neither does cp?
rsync -avhPrq /Volumes/AnypointStudio/AnypointStudio.app /Applications/ 

# own it
chown -R $currentUser /Applications/AnypointStudio.app 

# dismount
hdiutil unmount /Volumes/AnypointStudio 

# cleanup
rm /Library/Application\ Support/JAMF/Waiting\ Room/"${DMG}"*

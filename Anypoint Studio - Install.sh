#!/usr/bin/env bash

# TO-DO:
# pass filename as param 4, validate


# this assumes that you have cached AnypointStudio-VER-{ARCH}.dmg to Waiting Room

# variables
currentUser=$( stat -f%Su /dev/console ) 

# mount
hdiutil mount /Library/Application\ Support/JAMF/Waiting\ Room/AnypointStudio-7.24.0-macosArm.dmg

# ditto doesn't seem to work reliably, neither does cp?
rsync -avhPrq /Volumes/AnypointStudio/AnypointStudio.app /Applications/ 

# own it
chown -R $currentUser /Applications/AnypointStudio.app 

# dismount
hdiutil unmount /Volumes/AnypointStudio 

# cleanup
rm /Library/Application\ Support/JAMF/Waiting\ Room/AnypointStudio*

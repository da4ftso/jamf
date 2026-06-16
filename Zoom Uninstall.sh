#!/bin/bash

# variables

lastUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }' )
currentUser=$(/usr/bin/stat -f%Su "/dev/console")
userHome=$(/usr/bin/dscl . -read "/Users/$currentUser" NFSHomeDirectory | /usr/bin/awk ' { print $NF } ')

if [ "$currentUser" == "" ] || [ "$currentUser" == "root" ]; then
 userHome=$(/usr/bin/dscl . -read "/Users/$lastUser" NFSHomeDirectory | /usr/bin/awk ' { print $NF } ')
fi

# bootout LaunchDaemon

plist="/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist"

launchd=$(launchctl list | grep -iE wireshark)
if [[ -n "$launchd" ]]; then
	launchctl bootout system "$plist"
fi    

# remove files

list=(
"/Applications/zoom.us.app"
"/Library/Application Support/zoom.us/"
"/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist"
"$userHome/Library/Caches/us.zoom.xos/"
"$userHome/Library/HTTPStorages/us.zoom.xos/"
"$userHome/Library/Logs/zoom.us/"
)

for i in "${list[@]}"; do
        if [[ -e $i ]]; then
                rm -rf "$i" || exit
                echo "Removing $i .."
        fi  
done    

# https://gitlab.com/wireshark/wireshark/-/issues/18734

# pkgutil --forget org.wireshark.Wireshark
# pkgutil --forget org.wireshark.ChmodBPF.pkg

for i in $(/usr/sbin/pkgutil --pkgs | grep -iE zoom ); do
        pkgutil --forget "$i"
done

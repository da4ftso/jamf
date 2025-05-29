#!/bin/bash

# variables

currentUser=$(stat -f %Su "/dev/console")
currentUserHome=$(dscl . read "/Users/$currentUser" NFSHomeDirectory | awk ' { print $NF } ')

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
"$currentUserHome/Library/Caches/us.zoom.xos/"
"$currentUserHome/Library/HTTPStorages/us.zoom.xos/"
"$currentUserHome/Library/Logs/zoom.us/"
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

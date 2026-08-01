#!/bin/bash

# Remove the following:
# - Wireshark.app from /Applications
# - ChmmodBPF launch daemon & script
# - access_bpf group from dscl
# - HTTPStorages folder
# - system package receipts (leaving Jamf receipts)

# variables

currentUser=$(stat -f %Su "/dev/console")
currentUserHome=$(dscl . read "/Users/$currentUser" NFSHomeDirectory | awk ' { print $NF } ')

# remove LaunchDaemon

CHMOD_BPF_PLIST="/Library/LaunchDaemons/org.wireshark.ChmodBPF.plist"
BPF_GROUP="access_bpf"

launchd=$(launchctl list | grep -iE wireshark)
if [[ -n "$launchd" ]]; then
	launchctl bootout system "$CHMOD_BPF_PLIST"
fi    

# remove group from dscl

dscl . -read /Groups/"$BPF_GROUP" > /dev/null 2>&1 && \
    dseditgroup -q -o delete "$BPF_GROUP" 2>&1

# remove files
# ChmodBPF hasn't been a startup item since 2018 (ac4f3c0f4d)

list=(
"/Applications/Wireshark.app"
"/Library/Application Support/Wireshark"
"/Library/LaunchDaemons/org.wireshark.ChmodBPF.plist"
"/Library/StartupItems/ChmodBPF"
"$currentUserHome/Library/HTTPStorages/org.wireshark.Wireshark/"
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

for i in $(/usr/sbin/pkgutil --pkgs | grep -iE wireshark ); do
        pkgutil --forget "$i"
done

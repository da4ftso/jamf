#!/bin/bash
set -x

# 1.0.1 unattended install for MyEclipse 2025.12 - cloned from the 2022 version & improved
#
# TO-DO: change from hardcoded installer version and pass param 4
#    (but that will require some detection logic to verify DMG)
#  more logging
#  unmount the volume after standard-install has completed
#  clean-up the DMG
#  clean up the response.txt

# variables

currentUser=$(/usr/bin/stat -f%Su "/dev/console")
cacheDir=/Library/Application\ Support/JAMF/Waiting\ Room
file="myeclipse-2025.2.0-offline-installer-macosx.dmg"

# check for .sparsebundle

if [ ! -e "${cacheDir}"/$file ]; then
	echo "Installer not found, exiting.."
    exit 1
fi

# mount up

/usr/bin/hdiutil mount -nobrowse -quiet "${cacheDir}"/$file
sleep 2

# cat out the response.txt https://www.genuitec.com/forums/topic/unattended-installation/

cat << EOF > "/private/var/tmp/response.txt"
directory.profile=/Applications/MyEclipse
osgi.os=macosx
osgi.ws=cocoa
osgi.arch=x86_64
result.file=/Users/Shared/myeclipse-install.log

EOF

# install (automatic but not silent)

/usr/bin/sudo -u "$currentUser" /Volumes/MyEclipse/MyEclipse\ 2025.2.0\ Installer.app/Contents/MacOS/standard-install --unattended /private/var/tmp/response.txt


exit 0

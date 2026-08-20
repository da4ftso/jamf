#!/bin/bash
set -x

# 1.0.4 unattended install for MyEclipse 2025.12 - cloned from the 2022 version & improved
#
# TO-DO: change from hardcoded installer version and pass param 4
#    (but that will require some detection logic to verify DMG)
#  more logging

# variables

currentUser=$(/usr/bin/stat -f%Su "/dev/console")
cacheDir=/Library/Application\ Support/JAMF/Waiting\ Room
file="myeclipse-2025.2.0-offline-installer-macosx.dmg"

# check for .sparsebundle

if [ ! -e "${cacheDir}"/$file ]; then
	echo "Installer not found, exiting.."
    exit 1
fi

# mount up - removing the nobrowse during testing

# /usr/bin/hdiutil mount -nobrowse -quiet "${cacheDir}"/$file
/usr/bin/hdiutil mount -quiet "${cacheDir}"/$file
sleep 2

# cat out the response.txt https://www.genuitec.com/forums/topic/unattended-installation/

cat <<-EOF > "/private/var/tmp/response.txt"
	directory.profile=/Applications/MyEclipse
	osgi.os=macosx
	osgi.ws=cocoa
	osgi.arch=x86_64
	result.file=/Users/Shared/myeclipse-install.log
	EOF

# install (automatic but not silent)

/usr/bin/sudo -u "$currentUser" /Volumes/MyEclipse/MyEclipse\ 2025.2.0\ Installer.app/Contents/MacOS/standard-install \
--unattended /private/var/tmp/response.txt

# unmount the volume after standard-install has completed
#
# the below doesn't seem to work?
# while pgrep -f standard-install > /dev/null ; do
# 	sleep 2
# done

# pids=$(pgrep -f standard-install || true)
# if [ -z "$pids" ]; then
# 	echo "No installer running.."
# else
# 	while kill -0 $(echo $pids)	2>/dev/null; do
# 		sleep 2
# 	done
# 	echo "standard-install has completed, unmounting.."	
# 	/usr/bin/hdiutil unmount /Volumes/MyEclipse
# fi	

sleep 90 # about a minute on modern systems, but pad it jic

/usr/bin/hdiutil unmount /Volumes/MyEclipse	

rm -rf "${cacheDir}"/$file
rm /private/var/tmp/response.txt

exit 0

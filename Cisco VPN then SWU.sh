#!/bin/bash

# 0.3 221108 PWC
#
# check for VPN connection, warn if connected, open SWU, start SWU if i386

# SELF SERVICE will kick off SWU directly for now
# SUPER will be run directly for laggards beginning Nov. XXth


# variables

currentUser=$(/usr/bin/stat -f%Su "/dev/console")
uid=$(/usr/bin/id -u "$currentUser")

platform=$(/usr/bin/arch)

# jamfHelper

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

heading="Active VPN Detected"

description="• Please close all documents and remote sessions; \n
• Disconnect from the VPN; \n
• Re-run this task."

button1="Retry"

icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"

msg=$( printf "$description" )


# check for VPN connection

vpnstatus=$(/opt/cisco/anyconnect/bin/vpn state | awk '/state:/ { print $NF; exit } ')
#echo $vpnstatus

if [[ "$vpnstatus" = "Connected" ]]; then

	# message to disconnect vpn

	"$jamfHelper" -windowType utility -heading "$heading" -description "$msg" -button1 "$button1" -defaultButton 1 -icon "$icon"
	
	exit 0
	
else	

	# kickstart service

	/bin/launchctl kickstart -k system/com.apple.softwareupdated

	# open Sys Prefs

	/bin/launchctl asuser "$uid" open /System/Library/PreferencePanes/SoftwareUpdate.prefPane
	
	# if Intel, launch softwareupdate specific 12.6.1
	
	if [[ "$platform" = "i386" ]]; then
	
		/usr/sbin/softwareupdate --fetch-full-installer --full-installer-version "12.6.1"
		echo "Requesting macOS Monterey 12.6.1 Installer..."
	fi	
	
fi	

exit 0

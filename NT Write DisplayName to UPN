#!/bin/bash

# 1.0 241106
# unload Nexthink's plists, update UPN collection to cleartext, reload plists; 
# read Office 365 Activation; write out to fake Jamf Connect plist.
# if no email address is found, an empty file will be touched instead.
#
# use this if your Macs aren't bound to AD and you're not a Jamf Connect shop.
#
# TO-DO: 
#. Jamf Pro API call to read email from computer inventory > location.
#. sanity check for the LaunchDaemons?

# variables

nxtsvcPlist="/Library/LaunchDaemons/com.nexthink.collector.driver.nxtsvc.plist"
nxtcoordPlist="/Library/LaunchDaemons/com.nexthink.collector.nxtcoordinator.plist"

currentUser=$(stat -f %Su "/dev/console")
currentUserHome=$(dscl . read "/Users/$currentUser" NFSHomeDirectory | awk ' { print $NF } ')
uid=$(id -u "$currentUser")

plistPath="${currentUserHome}"/Library/Preferences/com.jamf.connect.state.plist

config="/Library/Application Support/Nexthink/config.json"

# functions
validate() {
	# check for Nexthink, bail out if not present
	if [[ ! -e $config ]]; then
	  echo "X Nexthink collector not found, exiting.."
	  exit 1
	else
	  echo "= Collector version:" "$(/usr/bin/awk -F\" '/version/ { print $4 }' "$config")"
	fi
}	

unloadPlists() {
	echo "- Unloading .plists.."
	/bin/launchctl unload "${nxtsvcPlist}"
	/bin/launchctl unload "${nxtcoordPlist}"
}

editConfig() {
	echo "> Setting collection to cleartext.."
	/usr/bin/sed -i '' 's/\"no_import\"/\"cleartext\"/' "${config}"
}

reloadPlists() {
	echo "+ Reloading .plists.."
	/bin/launchctl load "${nxtsvcPlist}"
	/bin/launchctl load "${nxtcoordPlist}"
}

getEmail() {
        email=$(launchctl asuser "$uid" sudo -u "$currentUser" /usr/bin/defaults read com.microsoft.office OfficeActivationEmailAddress)

        if [[ "{$email}" != *"@"* ]]; then
	        echo "no @ found, exiting.."
                touch "{$plistPath}"
	        exit 0
        fi     
}

writePlist() {
        /usr/libexec/PlistBuddy -c "Add DisplayName string" "${plistPath}" > /dev/null 2>&1
        /usr/libexec/PlistBuddy -c "Set DisplayName $email" "${plistPath}" > /dev/null 2>&1
        # echo "Wrote $email to $plistPaht"
}

# execution

	validate
	unloadPlists
	editConfig
	reloadPlists
	getEmail
	writePlist

exit

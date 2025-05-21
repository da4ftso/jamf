#!/bin/bash

# Jamf version, take param $4 and use as load or unload.
# remember to set Before and After if using two instances of script
# to unload then reload.

# rather than an EA, we're also going to run a check for both TCP
# connectivity and plist load/run status.

# no need for currentUser or currentUserHome *unless* we also have
# to restart nxtray.plist as it is a LA not LD

# TO-DO: add "clean" to param $4 which will unload plists and then
# remove various temp files as well as the plists - this will require
# reinstalling the PKG or at least re-running the activation script.

# TO-DO: merge with 2023 Nexthink script

# variables

action="$4" # specify the actual launchctl commands in script Options
action=${action,,} # bash substitution only, can't use in zsh

if [[ "$action" == "" ]]; then
	echo "No launchctl action specified, exiting.."
	exit 0
fi	

plists=(
"/Library/LaunchDaemons/com.nexthink.collector.driver.nxtsvc.plist"
"/Library/LaunchDaemons/com.nexthink.collector.nxtbsm.plist"
"/Library/LaunchDaemons/com.nexthink.collector.nxtcod.plist"
"/Library/LaunchDaemons/com.nexthink.collector.nxteufb.plist"
"/Library/LaunchDaemons/com.nexthink.collector.nxtcoordinator.plist"
"/Library/LaunchDaemons/com.nexthink.collector.nxtupdater.plist"
"/Library/LaunchDaemons/com.nexthink.audit.config.plist"
)

if [[ "$action" == "unload" ]]; then
	action="unload -w"
fi	

for i in ${plists[@]}
	do
		if [[ -e "$i" ]]; then
		launchctl "$action" "$i"
		fi
	done

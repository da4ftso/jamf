#!/bin/bash
# set -x

# 1.1 231116 PWC
# unload Nexthink's plists; edit config to trace; reload; run reporter; unload plists; revert to warn; reload
# TODO: check for logged in user, export to /Users/Shared otherwise
#    do we want to add any elapsed time logging?
#    add a 'are we running from jamf' check
#    add cmd-line interactive features (help, verbose, clean)


# variables
currentUser=$(stat -f %Su "/dev/console")
currentUserHome=$(dscl . read "/Users/$currentUser" NFSHomeDirectory | cut -d: -f 2 | sed 's/^ *//'| tr -d '\n')
outputDir="{currentUserHome}/Nexthink-Reporter"

nxtsvcPlist="/Library/LaunchDaemons/com.nexthink.collector.driver.nxtsvc.plist"
nxtcoordPlist="/Library/LaunchDaemons/com.nexthink.collector.nxtcoordinator.plist"
reporter="/private/var/tmp/reporter" # edit path if necessary

hostname=$(/bin/hostname)

currentTime=$(date "+%Y%m%d_%H%M") # 20231116_1516
config="/Library/Application Support/Nexthink/config.json"

# functions
validate() {
	# check for Nexthink, bail out if not present
	if [[ ! -e $config ]]; then
	  echo "Nexthink collector not found, exiting.."
	  exit 1
	else
	  echo "Collector version:" "$(/usr/bin/awk -F\" '/version/ { print $4 }' "$config")"
	fi

	# check for reporter, bail out if not present OR call from Jamf policy 
	if [[ ! -e "${reporter}" ]]; then
		/usr/local/bin/jamf policy -event run-ntr
		sleep 1
	else
		echo "Nexthink reporter not found, exiting.."
		exit 1
	fi
	
	# check if reporter can be executed, fix if not?
}

unloadPlists() {
	echo "Unloading .plists.."
	/bin/launchctl unload "${nxtsvcPlist}"
	/bin/launchctl unload "${nxtcoordPlist}"
}

editConfig() {
	echo "Setting config to trace.."
	/usr/bin/sed -i '' 's/\"warning\"/\"trace\"/' "${config}"
}

revertConfig() {
	echo "Setting config to warning.."
	/usr/bin/sed -i '' 's/\"trace\"/\"warning\"/' "${config}"
}

reloadPlists() {
	echo "Reloading .plists.."
	/bin/launchctl load "${nxtsvcPlist}"
	/bin/launchctl load "${nxtcoordPlist}"
}

runReporter() {
	echo "Running reporter.."
	"${reporter}" > /dev/null 2>&1
}

collectOutput() {
	# check for Reporter output dir, create if not
	if [[ ! -e "${outputDir}" ]]; then
		mkdir "${outputDir}"
		echo "Creating output directory.."
	fi
	mkdir "${outputDir}"/"${currentTime}"  # if we have to run this multiple times
	mv "${currentUserHome}"/Nexthink_Reporter.zip "${outputDir}"/"${currentTime}"/Nexthink_Reporter-"${hostname}".zip
	if [[ -e /Library/Logs/nxtray.log ]]; then
		cp /Library/Logs/nxtray.log "${outputDir}"/"${currentTime}"
	fi
	if [[ -e /Library/Logs/nxtcoordinator.log ]]; then
		cp /Library/Logs/nxtcoordinator.log "${outputDir}"/"${currentTime}"
	fi
	/bin/chmod -R 755 "${outputDir}"/"${currentTime}"
}

# executive dysfunction, amirite

	unloadPlists

	editConfig

	reloadPlists

	runReporter

	unloadPlists

	revertConfig

	reloadPlists

	collectOutput

echo "Nexthink Reporter output to ${outputDir}"

# reveal the .zip to user, prompt user to Do Something, OR
# figure out a way to transmit file to IT (scp to a host?)


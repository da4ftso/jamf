#!/bin/bash

# TO-DO: output file to include LocalHostName

# variables
currentUser=$( stat -f%Su /dev/console )
currentUserHome=$(eval echo "~$currentUser")


# logged in user
if [[ -z "$currentUser" || "$currentUser" == "root" ]]; then
	echo "No currently logged in user"
	exit 1
fi

# output to current user's Desktop
# filename will contain timestamp:
# "sysdiagnose_2025.10.08_13-56-50-0500_macOS_Mac_25B5057f.tar.gz"
/usr/bin/sysdiagnose -u -f "$currentUserHome"/Desktop/ 2>&1

exit 0

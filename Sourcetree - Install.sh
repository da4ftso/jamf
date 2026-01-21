#!/bin/bash

# Sourcetree v4 has a long-standing bug related to translocation (or something)
# just packaging it as normal results in a 'broken' app
# autopkg recipes will often use a chown processor

# TO-DO: better filtering in Waiting Room in case there are other old .ZIPs
#  can we suppress all outputs instead of multiple /dev/null statements?

# variables
currentUser=$(who | awk 'NR==1{ print $1 } ') ; 
path="/Library/Application Support/JAMF/Waiting Room/"

# if -e then unzip
if ls "$path"/*.zip >/dev/null 2>&1; then
	unzip "$path"/*.zip -d /Users/Shared/ >/dev/null 2>&1
	rm "$path"/*.zip
else
	echo "Sourcetree.zip not found, exiting.."
    exit 1
fi

mv /Users/Shared/Sourcetree.app /Applications/ >/dev/null 2>&1

chown -R "$currentUser" /Applications/Sourcetree.app

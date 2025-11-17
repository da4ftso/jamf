#!/bin/bash

# update all the things (quietly)
# check individual policy logs for results to minimize redundancy in the db
# you are using custom event names for everything, right?

policiesToRun=(
"install-company-portal-test"
"install-googlechrome"
"install-homebrew-pkg"
"install-edge"
"install-iterm2"
"install-jsp-2"
"install-mswinapp"
"install-nexthink"
"install-onedrive-beta"
"install-tanium"
"install-teams-beta"
"install-vscode"
"install-webex"
"install-webex-meetings"
"install-wireshark"
"install-zoom"
)

for policy in "${policiesToRun[@]}"
	do
		/usr/local/bin/jamf policy -event "${policy}" 2>&1
	done	

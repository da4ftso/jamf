#!/bin/bash

# to-do: check launchctl for Agent* and only bootout if found

if [ -e "/Applications/MagnetNexus/Agent.app" ] || [ -e "/Applications/MagnetNexus/NexusAgentA.app" ] ; then

	/bin/launchctl bootout system/Agent
	/bin/launchctl stop Agent

files=(
	"/Library/LaunchDaemons/Agent.plist"
    "/Library/LaunchDaemons/NexusAgentA.plist"
    "/Library/LaunchDaemons/NexusAgentB.plist"
    "/Applications/MagnetNexus/"
)

	for f in "${files[@]}"; do
		if [[ -e "$f" ]]; then
    		echo "Deleting ""$f"
	        rm -rf "$f"
		fi
		done
        
else
	echo "MagnetNexus Agent not found, exiting..."
fi

exit 0

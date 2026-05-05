#!/bin/bash

# 1.0.2

if [ -e "/Applications/MagnetNexus/Agent.app" ] || [ -e "/Applications/MagnetNexus/NexusAgentA.app" ] || [ -e "/Applications/MagnetNexus/NexusAgentB.app" ] ; then

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
	        rm -Rf "$f"
		fi
		done
        
else
	echo "MagnetNexus Agent not found, exiting..."
fi

exit 0

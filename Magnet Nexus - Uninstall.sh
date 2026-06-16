#!/bin/bash

# 1.1

AGENT_APPS=(
	"/Applications/MagnetNexus/Agent.app"
	"/Applications/MagnetNexus/NexusAgentA.app"
	"/Applications/MagnetNexus/NexusAgentB.app"
)

LAUNCH_DAEMONS=(
	"/Library/LaunchDaemons/Agent.plist"
	"/Library/LaunchDaemons/NexusAgentA.plist"
	"/Library/LaunchDaemons/NexusAgentB.plist"
)

AGENT_DIR="/Applications/MagnetNexus/"

# Check if any agent app exists
agent_found=false
for app in "${AGENT_APPS[@]}"; do
	if [[ -e "$app" ]]; then
		agent_found=true
		break
	fi
done

if [[ "$agent_found" == false ]]; then
	echo "MagnetNexus Agent not found, exiting..."
	exit 0
fi

# Unload and stop launch daemons
for daemon in "${LAUNCH_DAEMONS[@]}"; do
	if [[ -e "$daemon" ]]; then
		echo "Stopping launchd daemon: $daemon"
		/bin/launchctl bootout "system/$(basename "$daemon" .plist)" 2>/dev/null
		/bin/launchctl stop "$(basename "$daemon" .plist)" 2>/dev/null
	else
		echo "Daemon not found: $daemon"
	fi
done

# Remove files and directories
files_to_remove=(
	"${LAUNCH_DAEMONS[@]}"
	"$AGENT_DIR"
)

for f in "${files_to_remove[@]}"; do
	if [[ -e "$f" ]]; then
		echo "Deleting: $f"
		rm -Rf "$f"
	fi
done

echo "Uninstall complete."
exit 0

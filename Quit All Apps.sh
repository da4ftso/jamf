#!/bin/bash

# Quit All Apps 1.0.2
#
# Use this as a Before script for a 'big red button' one-click approach to updating apps.
#
# The 'app_mode_loader' appears to be a component of Google Chrome that is active if you're using a PWA.
# 
# You should be careful with Cisco AnyConnect / Secure Client or similar network clients.
# Remove the Script Editor once you're done fine-tuning.

# Define output file for process list - accessible to other scripts
PROCESS_LIST="/tmp/running_processes.txt"

# Capture list of all visible application processes before quitting
osascript -e 'tell application "System Events" to set all_processes to name of every application process whose visible is true' | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' > "$PROCESS_LIST"

# Log the captured processes
echo "$(date): Captured $(wc -l < "$PROCESS_LIST") running processes to $PROCESS_LIST" >> /tmp/quit_all_apps.log

# Get list of apps to quit (exclude system apps and network clients)
osascript -e 'tell application "System Events" to set quitapps to name of every application process whose visible is true and name is not "Finder" and name is not "Cisco Secure Client" and name is not "app_mode_loader"
repeat with closeall in quitapps
	quit application closeall
	delay 10
end repeat'

exit

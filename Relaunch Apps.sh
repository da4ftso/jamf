#!/bin/bash

# Relaunch Apps 1.0.0
#
# Use this as an After script to relaunch all applications that were quit.
# Reads the process list created by "Quit All Apps.sh" from /tmp/running_processes.txt

PROCESS_LIST="/tmp/running_processes.txt"

# Check if the process list file exists
if [ ! -f "$PROCESS_LIST" ]; then
    echo "Error: Process list file not found at $PROCESS_LIST" >> /tmp/relaunch_apps.log
    exit 1
fi

echo "$(date): Starting to relaunch applications from $PROCESS_LIST" >> /tmp/relaunch_apps.log

# Read each process name and launch it
while IFS= read -r app_name; do
    # Skip empty lines
    [ -z "$app_name" ] && continue
    
    echo "$(date): Attempting to launch: $app_name" >> /tmp/relaunch_apps.log
    
    # Use osascript to launch the application
    osascript -e "tell application \"$app_name\" to activate" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "$(date): Successfully launched: $app_name" >> /tmp/relaunch_apps.log
    else
        echo "$(date): Failed to launch: $app_name" >> /tmp/relaunch_apps.log
    fi
    
    # Add a delay between launches to avoid overwhelming the system
    sleep 2
    
done < "$PROCESS_LIST"

echo "$(date): Relaunch process completed" >> /tmp/relaunch_apps.log

exit

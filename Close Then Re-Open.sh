#!/bin/bash

# Set to run Before, typically

# Name of the app to check (e.g., "Safari")
APP_NAME="$4"
APP_NAME="${APP_NAME%.app}" # shell expansion to remove .app

# Function to check if the app is running
# Pass -x for exact matching
is_app_running() {
    pgrep "$APP_NAME" > /dev/null 2>&1
    return $?
}

# Check if the app is running
is_app_running
APP_WAS_RUNNING=$?

# If the app is running, close it
if [ $APP_WAS_RUNNING -eq 0 ]; then
    echo "$APP_NAME is running. Closing it..."
    osascript -e "tell application \"$APP_NAME\" to quit"
    sleep 2 # Allow some time for the app to quit
else
    echo "$APP_NAME is not running."
fi

# Do Stuff here
echo "Executing another command, like jamf policy -event install-something..."

# Reopen the app if it was originally running
if [ $APP_WAS_RUNNING -eq 0 ]; then
    echo "Reopening $APP_NAME..."
    open -a "$APP_NAME"
else
    echo "$APP_NAME will remain closed."
fi

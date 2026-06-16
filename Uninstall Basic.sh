#!/bin/bash

# Parameter 4: app name
# This script robustly parses the app name to ensure proper path format

if [ "$4" == "" ]; then
  echo "No app name specified, exiting.."
  exit 1
fi  

# Parse and normalize the app path
APP_NAME="$4"

# Add /Applications prefix if not present
if [[ "$APP_NAME" != /* ]]; then
  APP_NAME="/Applications/$APP_NAME"
fi

# Add .app extension if not present
if [[ "$APP_NAME" != *.app ]]; then
  APP_NAME="${APP_NAME}.app"
fi

echo "Resolved app path: $APP_NAME"

# Remove files and directories
if [[ -e "$APP_NAME" ]]; then
	echo "Deleting: $APP_NAME"
	rm -Rf "$APP_NAME"
	echo "Uninstall complete."
else
	echo "Warning: App not found at $APP_NAME"
fi

exit 0

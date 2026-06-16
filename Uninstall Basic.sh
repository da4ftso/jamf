#!/bin/bash

# param 4: app name
# sanitize to add ".app" and correct path

if [ "$4" == "" ]; then
  echo "No app name specified, exiting.."
  exit 1
fi  

# app path
APP_NAME="$4"

# add /Applications prefix
if [[ "$APP_NAME" != /* ]]; then
  APP_NAME="/Applications/$APP_NAME"
fi

# add .app extension
if [[ "$APP_NAME" != *.app ]]; then
  APP_NAME="${APP_NAME}.app"
fi

# echo "Resolved app path: $APP_NAME"

# rm
if [[ -e "$APP_NAME" ]]; then
	echo "Deleting: $APP_NAME"
	rm -Rf "$APP_NAME"
	# echo "Uninstall complete."
else
	echo "Warning: App not found at $APP_NAME"
	# exit 1
fi

exit 0

#!/bin/bash

# 1.0.1 260715

set -o errexit
set -o nounset
set -o pipefail

# 4 = add, needs entire path and .app
# 5 = replaces, only needs label - no path or .app
# ex: dockutil --add /Applications/Microsoft Edge.app --replacing 'Google Chrome'

appName="${4:-}"
replaceLabel="${5:-}"

# if this or that is empty
if [[ -z "$appName" || -z "$replaceLabel" ]]; then
    echo "Missing parameter(s)."
    exit 1
fi

# sanitize appName

if [[ "$appName" != /* ]]; then
  appName="/Applications/$appName"
fi

# add .app extension
if [[ "$appName" != *.app ]]; then
  appName="${appName}.app"
fi

# echo "Resolved app path: $APP_NAME"

# not strictly necessary

currentUser="$(stat -f '%Su' /dev/console)"

if [[ "$currentUser" == "loginwindow" ]]; then
    echo "No user logged in."
    exit 1
fi

uid="$(id -u "$currentUser")"
appPath="/Applications/${appName}"

# make sure app to add exists

if [[ ! -d "$appPath" ]]; then
    echo "Application not found: $appPath"
    exit 1
fi

# check for dockutil, install and verify if not

if [[ ! -x "/usr/local/bin/dockutil" ]]; then
    /usr/local/bin/jamf policy -event install-dockutil

    [[ -x "/usr/local/bin/dockutil" ]] || {
        echo "dockutil installation failed."
        exit 1
    }
fi

# wait for Dock if running at login

until pgrep -xu "$currentUser" Dock >/dev/null; do
    sleep 2
done

# echo "Adding '$appName' to Dock for '$currentUser'"

launchctl asuser "$uid" sudo -u "$currentUser" \
    /usr/local/bin/dockutil --add "$appPath" --replacing "$replaceLabel"

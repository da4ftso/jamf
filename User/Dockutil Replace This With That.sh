#!/bin/bash

# 1.4 260811

# consider running as "z - Dockutil" etc to run last after any other scripts

# param 4: App Name to add
itemAdd="${4:-}"

# param 5: App Label to be replaced
itemReplace="${5:-}"

# validate params
[[ -z "${itemAdd}" ]] || [[ -z "${itemReplace}" ]]&& {
    echo "No application specified."
    exit 0
}

# currently logged-in user
currentUser=$(/usr/bin/stat -f "%Su" /dev/console)

# App Name to /Applications/app name .app
app="${itemAdd}"
prefix="/Applications/"
suffix=".app"

# remember this shell expansion requires bash, don't change to zsh

# check if app doesnt contain the prefix
if [[ "${app}" != *"$prefix"* ]]; then
    app="${prefix}${app}"
fi

# check if app doesnt contain the suffix
if [[ "${app}" != *"$suffix"* ]]; then
    app="${app}${suffix}"
fi

# sanity check
if [[ ! -x "${app}" ]]; then
    echo "Application not found: $itemAdd"
    exit 0
fi

# if already in the user's Dock do nothing, otherwise -R (replace) in same position
if /usr/local/bin/dockutil --find "$app" "/Users/$currentUser" >/dev/null 2>&1; then
#    echo "Already present. No changes made. Bye."
    exit 0
else
    /usr/local/bin/dockutil --add "$app" -R "${itemReplace}" --no-restart "/Users/$currentUser" >/dev/null 2>&1;
    sleep 3
    /usr/bin/killall Dock
fi

exit 0

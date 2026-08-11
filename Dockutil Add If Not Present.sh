#!/bin/bash

# item to add (param 4) - shell expansion
item="${4:-}"

# validate
[[ -z "${item}" ]] && {
    echo "No application specified."
    exit 0
}

# currently logged-in user
currentUser=$(/usr/bin/stat -f "%Su" /dev/console)

app="${item}"
prefix="/Applications/"
suffix=".app"

# doesnt contain the prefix
if [[ "${app}" != *"$prefix"* ]]; then
    app="${prefix}${app}"
fi

# doesnt contain the suffix
if [[ "${app}" != *"$suffix"* ]]; then
    app="${app}${suffix}"
fi

# bail out if app not found
if [[ ! -x "${app}" ]]; then
    echo "Application not found: $item"
    exit 0
fi

# already in the user's Dock do nothing, otherwise add
if /usr/local/bin/dockutil --find "$app" "/Users/$currentUser" >/dev/null 2>&1; then
#    echo "Already present. No changes made. Bye."
    exit 0
else
    /usr/local/bin/dockutil --add "$app" -s apps -p end --no-restart "/Users/$currentUser" >/dev/null 2>&1;
    sleep 3
    /usr/bin/killall Dock
fi

exit 0

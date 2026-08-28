#!/bin/bash

# 1.1 250517
# can we get App Label out of actual .app etc?

# consider running as "x - Docktuil" etc to ensure running last after other scripts

# App Label to remove (not path or filename)
item="$4"

# Determine the currently logged-in user
currentUser=$(/usr/bin/stat -f "%Su" /dev/console)

# # Exit if nobody is logged in
# if [[ -z "$CURRENT_USER" || "$CURRENT_USER" == "root" ]]; then
#     echo "No logged-in user detected."
#     exit 0
# fi

# echo "Checking Dock for '$item' for user '$currentUser'..."

# Check whether the item exists in the user's Dock
if /usr/local/bin/dockutil --find "$item" "/Users/$currentUser" >/dev/null 2>&1; then
#    echo "Found '$item'. Removing it from the Dock..."

    /usr/local/bin/dockutil --remove "$item" --no-restart "/Users/$currentUser"
    sleep 3

    # only restart Dock if a change was actually made
    /usr/bin/killall Dock

#    echo "Dock item removed."
# else
#    echo "Dock item not present. No changes made and Dock not restarted."
fi

exit 0

#!/bin/bash

# chowner
# 1.0.1 261110

# param 4 - full path to item/dir
# param 5 - [currently logged in user], "last," or

# params sanity check
if [[ -n "${4:-}" ]]; then
    target="$4"
else
    echo "Target not specified, exiting.."
    exit 1
fi

if [[ -n "${5:-}" ]]; then
    requestedUser="$5"
else
    echo "User not specified, exiting.."
    exit 1
fi

# user
if [[ "$requestedUser" == "last" ]]; then

    # last logged-in
    user=$(/usr/bin/defaults read /Library/Preferences/com.apple.loginwindow lastUserName 2>/dev/null)

    if [[ -z "$user" ]]; then
        echo "Unable to determine last logged-in user, exiting.."
        exit 1
    fi

    # last user exists
    if ! /usr/bin/dscl . -read "/Users/$user" >/dev/null 2>&1; then
        echo "Last logged-in user '$user' is not a local account, exiting.."
        exit 1
    fi

else

    # existing local user
    if /usr/bin/dscl . -read "/Users/$requestedUser" >/dev/null 2>&1; then
        user="$requestedUser"
    else
        echo "Local user '$requestedUser' not found, exiting.."
        exit 1
    fi

fi

# target
if [[ -e "$target" ]]; then
    echo "Changing ownership of '$target' to '$user'..."
    /usr/sbin/chown -R "$user" "$target"

    if [[ $? -ne 0 ]]; then
        echo "Failed to change ownership of '$target'."
        exit 1
    fi
else
    echo "'$target' not found, exiting.."
    exit 1
fi

exit 0

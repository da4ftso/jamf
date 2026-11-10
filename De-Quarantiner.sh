#!/bin/bash

# De-Quarantiner
# 1.1 261110 PWC

# param 4 - Full path, filename, or application name
#
#   1. Exact path supplied in Parameter 4
#   2. /Applications/<Parameter 4>
#   3. /Applications/<Parameter 4>.app
#
# Examples:
#   /Applications/Google Chrome.app
#   Google Chrome.app
#   Google Chrome

# sanity check
if [[ -n "${4:-}" ]]; then
    requestedTarget="$4"
else
    echo "ERROR: Target not specified, exiting."
    exit 1
fi

# target
if [[ -e "$requestedTarget" ]]; then

    # exact
    target="$requestedTarget"

elif [[ -e "/Applications/$requestedTarget" ]]; then

    # assume /Applications
    target="/Applications/$requestedTarget"

elif [[ -e "/Applications/${requestedTarget}.app" ]]; then

    # assume application name without .app
    target="/Applications/${requestedTarget}.app"

else
    echo "ERROR: Unable to locate '$requestedTarget'."
    echo "Checked:"
    echo "  $requestedTarget"
    echo "  /Applications/$requestedTarget"
    echo "  /Applications/${requestedTarget}.app"
    exit 1
fi

echo "Target resolved to '$target'."

# recursively recursive
if /usr/bin/xattr -r "$target" 2>/dev/null | \
    /usr/bin/grep -q "com.apple.quarantine"; then

    echo "com.apple.quarantine found on '$target'. Removing..."

    /usr/bin/xattr -dr com.apple.quarantine "$target" 2>/dev/null

    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to remove com.apple.quarantine from '$target'."
        exit 1
    fi

    # verify
    if /usr/bin/xattr -r "$target" 2>/dev/null | \
        /usr/bin/grep -q "com.apple.quarantine"; then

        echo "ERROR: com.apple.quarantine is still present on '$target'."
        exit 1
    fi

    echo "Successfully removed com.apple.quarantine from '$target'."

else
    echo "com.apple.quarantine is not set on '$target'. No action required."
fi

exit 0

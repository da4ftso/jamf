#!/bin/bash

OnNetwork=0

if ifconfig | awk '/inet / && $2 ~ /^10\./ { found=1 } END { exit !found }'; then
    OnNetwork=1
fi

if [[ -x /opt/cisco/secureclient/bin/vpn ]]; then
    if /opt/cisco/secureclient/bin/vpn state 2>/dev/null | grep -q "Connected"; then
        OnNetwork=1
    fi
fi

if [[ $OnNetwork -eq 1 ]]; then
    open -a OneDrive
else
    osascript -e 'tell application "OneDrive" to quit'
fi

exit 0

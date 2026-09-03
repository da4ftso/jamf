#!/bin/bash

# OneDrive connectivity check
# use with upgrades, shortcuts etc

OnNetwork=0

# assuming corp IP space with 10.x.x.x 
if ifconfig | awk '/inet / && $2 ~ /^10\./ { found=1 } END { exit !found }'; then
    OnNetwork=1
fi

# or maybe we're on the VPN
if [[ -x /opt/cisco/secureclient/bin/vpn ]]; then
    if /opt/cisco/secureclient/bin/vpn state 2>/dev/null | grep -q "Connected"; then
        OnNetwork=1
    fi
fi

# open -a tries to keep from app from opening in foreground
if [[ $OnNetwork -eq 1 ]]; then
    open -a OneDrive
else
    osascript -e 'tell application "OneDrive" to quit'
fi

exit 0

#!/bin/bash

# 2.0

killall Microsoft\ AutoUpdate          
killall Microsoft\ Update\ Assistant
rm -rf /Library/Application\ Support/Microsoft/MAU2.0
rm -rf /Library/LaunchAgents/com.microsoft.update.agent.plist
rm -rf /Library/LaunchDaemons/com.microsoft.autoupdate.helper.plist/usr/bin/pkill -x "Microsoft AutoUpdate" >/dev/null 2>&1 || true
/usr/bin/pkill -x "Microsoft Update Assistant" >/dev/null 2>&1 || true

for item in \
    "/Library/Application Support/Microsoft/MAU2.0" \
    "/Library/LaunchAgents/com.microsoft.update.agent.plist" \
    "/Library/LaunchDaemons/com.microsoft.autoupdate.helper.plist" \
    "/Library/PrivilegedHelperTools/com.microsoft.autoupdate.helper"
do
    [[ -e "$item" ]] && /bin/rm -rf "$item"
done
rm -rf /Library/PrivilegedHelperTools/com.microsoft.autoupdate.helper

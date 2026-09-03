#!/bin/bash

##
## use "OneDrive By IP.sh" instead
##

# quit OneDrive if it cannot establish a sync connection


CONSOLE_USER=$(stat -f "%Su" /dev/console)
CONSOLE_UID=$(id -u "${CONSOLE_USER}")

if ! pgrep -x "OneDrive" >/dev/null; then
exit 0
fi

for i in {1..6}; do
    if lsof -nP -a -c OneDrive -iTCP -sTCP:ESTABLISHED 2>/dev/null |
        grep -q -- '->.*:443'; then
        exit 0
    fi

    sleep 5
done

launchctl asuser "${CONSOLE_UID}" \
    osascript -e 'tell application "OneDrive" to quit' >/dev/null 2>&1

exit 0

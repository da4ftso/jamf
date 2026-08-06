#!/bin/bash

# 'Swift Default Apps' Outlook Handlers
# https://github.com/Lord-Kamina/SwiftDefaultApps
#!/bin/bash

# Set Outlook as handlers (runs in the currently logged-in user's environment)
currentUser=$(stat -f %Su /dev/console)

# ensure standard paths and user environment variables are available
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export HOME=$(eval echo "~$currentUser")
export USER="$currentUser"
export LOGNAME="$currentUser"

APP="/Applications/Microsoft Outlook.app"
SWDA="/usr/local/bin/swda"

if [ -x "$SWDA" ] && [ -d "$APP" ]; then
  "$SWDA" setHandler --app "$APP" --mail >/dev/null 2>&1
  "$SWDA" setHandler --app "$APP" --URL webcal >/dev/null 2>&1
  echo "Outlook handlers set"
  exit 0
else
  echo "Microsoft Outlook or swda not found" >&2
  exit 1
fi

#!/bin/bash

# shamelessly stole pbowden's EA to check for existence of the .dat
# to check whether OneDrive has been configured, exit if not -
# otherwise this will bring up the OneDrive login window every 5-10sec

# OneDrive .app / .appex MUST quit before loading this launchd job, otherwise
# users will report windows cycling badly enough to be quote 'unusable'

# the cycling/flashing behavior will also resume after every startup until
# OneDrive has been closed once

# variables

currentUser=$(stat -f%Su /dev/console)
uid=$(id -u "$currentUser")

HOME=$(dscl . read /Users/"$currentUser" NFSHomeDirectory | cut -d ':' -f2 | cut -d ' ' -f2)

# Find last modified time of sync file
DataFile=$(ls -t "$HOME"/Library/Application\ Support/OneDrive/settings/Business1/* | head -n 1)
if [ "$DataFile" != "" ]; then
	EpochTime=$(stat -f %m "$DataFile")
	UTCDate=$(date -u -r "$EpochTime" '+%m/%d/%Y')
	echo "<result>$UTCDate</result>"
else
	echo "OneDrive not configured, so no LaunchAgent to load.."
	exit 0
fi

plistPath="/Library/LaunchAgents/com.microsoft.onedrive.keepalive.plist"

cat << EOF > "$plistPath"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>KeepAlive</key>
	<true/>
	<key>Label</key>
	<string>com.microsoft.onedrive.keepalive</string>
	<key>Program</key>
	<string>/Applications/OneDrive.app/Contents/MacOS/OneDrive</string>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOF

# kill both OneDrive.app and OneDrive File Provider.appex

od_pids=$(pgrep "OneDrive")
for i in $od_pids; do
	kill -HUP "$i"
done    

chmod 644 "$plistPath"
chown "$currentUser":staff "$plistPath"

/bin/launchctl bootstrap gui/$uid "$plistPath"

# run in userspace to report accurately

sleep 1

if /bin/launchctl asuser "$uid" sudo -iu "$currentUser" /bin/launchctl list | grep -q com.microsoft.onedrive.keepalive ; then # https://www.shellcheck.net/wiki/SC2143
 	echo "KeepAlive job successfully loaded."
else
 	echo "KeepAlive job failed to load."
fi

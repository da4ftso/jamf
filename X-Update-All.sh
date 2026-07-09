#!/bin/bash

# this was basically MH's. 
#
# add osascript to gracefully close everything (don't forget sleep)
# merge with the newer version for array of policy events to run


echo START
date

caffeinate -di &

/usr/local/bin/jamf recon > /dev/null 2>&1 # no output, but since we're still on-prem this won't take too long

currentUser=$(/usr/bin/stat -f%Su "/dev/console")
uid=$(id -u "$currentUser")

runAsUser() {  
  if [ "$currentUser" != "loginwindow" ]; then
    launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
    echo "no user logged in"
    # uncomment the exit command
    # to make the function exit with an error when no user is logged in
    # exit 1
  fi
}

osascript -e 'tell application "System Events" to set quitapps to name of every application process whose visible is true and name is not "Finder" and name is not "Cisco Secure Client"
    repeat with closeall in quitapps
    quit application closeall
end repeat'

sleep 150

echo Update MS Office
jamf policy -event "install-msoffice"

echo Update MS Teams
jamf policy -event "install-msteams"


echo Update MS OneDrive
jamf policy -event "install-onedrive"

echo Update Google Chrome
jamf policy -event "install-googlechrome"

echo Update Webex
jamf policy -event "install-webex"

echo Update Microsoft Edge
jamf policy -event "install-edge"

echo Update Acrobat Reader
jamf policy -event "install-acrobatreader" # actually Adobe Acrobat

echo Update MS Defender
jamf policy -event "install-msdefender"

echo Update Nexthink Collector
jamf policy -event "install-nexthink"

/usr/local/bin/jamf recon > /dev/null 2>&1

killall caffeinate

echo FINISH
date

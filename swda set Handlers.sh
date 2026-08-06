#!/bin/bash

# 'Swift Default Apps' Outlook Handlers
# https://github.com/Lord-Kamina/SwiftDefaultApps

# variables
currentUser=$(stat -f %Su "/dev/console")
uid=$(id -u "$currentUser")

# run as user since Jamf runs scripts as root by default, and we're poking userspace
runAsUser() {  
  if [ "$currentUser" != "loginwindow" ]; then
    launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
    echo "no user logged in"
    # uncomment the exit command to make the function exit with an error when no user is logged in
    # exit 1
  fi
}

# set Outlook as handlers

if [ -e "/Applications/Microsoft Outlook.app" ]; then
  runAsUser /usr/local/bin/swda setHandler --app "/Applications/Microsoft Outlook.app" --mail
  echo "Outlook set as handler for mailto:"
  runAsUser /usr/local/bin/swda setHandler --app "/Applications/Microsoft Outlook.app" --URL webcal
  echo "Outlook set as handler for webcal:"
else
  echo "Microsoft Outlook not found, exiting.."
  exit 1
fi

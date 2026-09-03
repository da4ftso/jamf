#!/usr/bin/env bash

# set Chrome to use native macOS print dialog
# required for some Xerox job accounting to work properly

# https://chromeenterprise.google/policies/?policy=DisablePrintPreview
#     true = Disable Chrome print preview, use system instead
#    false = Enable Chrome print preview

# variables

currentUser=$(stat -f %Su "/dev/console") # pete
uid=$(id -u "$currentUser") # 501

# case insensitive

shopt -s nocasematch

# parameter

if [[ $4 == "enable" ]]; then
	value="true"
elif [[ $4 == "disable" ]]; then
	value="false"
else    
	echo "no value defined, exiting.."
fi

# run as user since Jamf runs scripts by default, and we're poking userspace

runAsUser() {  
  if [ "$currentUser" != "loginwindow" ]; then
    launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
    echo "no user logged in"
    # uncomment the exit command to make the function exit with an error when no user is logged in
    # exit 1
  fi
} 

runAsUser defaults write com.google.Chrome DisablePrintPreview -boolean "$value"

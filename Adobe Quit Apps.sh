#!/bin/bash

# use osascript to quit open Adobe apps ahead of running RUM or applying updates

# Define the array of process names
processes=("Adobe Acrobat"
"Adobe Acrobat DC"
"Adobe Bridge 2022"
"Adobe Bridge 2023"
"Adobe Photoshop 2022"
"Adobe Photoshop 2023"
"InDesign"
"Adobe Illustrator 2022"
"Adobe Illustrator 2023"
)

# If we're running this from Jamf Pro, we'll need to runAsUser

# current user
ConsoleUser="$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )"

# uid
uid=$(id -u "$ConsoleUser")

runAsUser() {  
  if [ "$ConsoleUser" != "loginwindow" ]; then
    launchctl asuser "$uid" sudo -u "$ConsoleUser" "$@"
  else
    echo "no user logged in"
    # uncomment the exit command
    # to make the function exit with an error when no user is logged in
    # exit 1
  fi
} 

# Loop through the array and quit each process
for process in "${processes[@]}"
do
runAsUser osascript -e "tell application \"$process\" to quit"
done

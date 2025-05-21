#!/bin/bash

## This allows you to specify lists of items to remove and add in arrays, and then they'll be done in bulk using a for loop
## Items to remove should be the label (usually the name of the application)
## Items to add are the full path to the item to add (usually /Applications/NAMEOFAPP.app)
## A few examples are prepopulated in the arrays, but feel free to tweak as suits the needs of your organization

# original https://raw.githubusercontent.com/aysiu/Mac-Scripts-and-Profiles/master/DockutilAddRemoveArrays.sh
# bash string manipulations here https://www.tldp.org/LDP/LG/issue18/bash.html

# check for dockutil, call a policy  with custom trigger "dockutil" to install if not already present

if [ ! -f "/usr/local/bin/dockutil" ]; then
    echo "Installing dockutil..";
    /usr/local/bin/jamf policy -trigger dockutil;
    sleep 5;
else
    echo "dockutil found at /usr/local/bin/, proceeding.."
fi

# define parameter 4 as the short admin account name

if [ $4 = "" ]; then
	echo "No admin username specified, exiting.."
	exit 1
fi

itemsToRemove=(
   "Address Book"
   "App Store"
   "Automator"
   "Books"
   "Calculator"
   "Calendar"
   "Chess"
   "Contacts"
   "Dashboard"
   "Dictionary"
   "Downloads"
   "FaceTime"
   "Font Book"
   "Home"
   "iBooks"
   "iPhoto"
   "Image Capture"
   "Keynote"
   "Launchpad"
   "Mail"
   "Maps"
   "Messages"
   "Mission Control"
   "News"
   "Notes"
   "Numbers"
   "Pages"
   "Photos"
   "Photo Booth"
   "Podcasts"
   "Preview"
   "QuickTime Player"
   "Reminders"
   "Siri"
   "Stickies"
   "Stocks"
   "TextEdit"
   "Time Machine"
   "TV"
   "Voice Memos"
)

# keeping to-add items verbose makes it ultimately easier to modify compared to passing $path

# to-do: check $majorOS and add Directory Utility from correct location

itemsToAdd=(
   "/Applications/Google Chrome.app"
   "/Applications/Safari.app"
   "/Applications/Utilities/Disk Utility.app"
   "/Applications/Utilities/Terminal.app"
   "/Applications/Utilities/Activity Monitor.app"
   "/Applications/Self Service.app"
   "/Applications/System Preferences.app"
)

for removalItem in "${itemsToRemove[@]}"
   do
      # Check that the item is actually in the Dock
      inDock=$(/usr/local/bin/dockutil --list | /usr/bin/grep "$removalItem")
      if [ -n "$inDock" ]; then
         /usr/local/bin/dockutil --remove "$removalItem" --no-restart
      fi
   done


for additionItem in "${itemsToAdd[@]}"
   do
      # Check that the item actually exists to be added to the Dock and that it isn't already in the Dock
      # Stripping path and extension code based on code from http://stackoverflow.com/a/2664746
      additionItemString=${additionItem##*/}
      additionItemBasename=${additionItemString%.*}
      inDock=$(/usr/local/bin/dockutil --list | /usr/bin/grep "additionItemBasename")
      if [ -e "$additionItem" ] && [ -z "$inDock" ]; then
            /usr/local/bin/dockutil --add "$additionItem" --no-restart
      fi
   done

/usr/bin/killall Dock

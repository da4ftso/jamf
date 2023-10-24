#!/bin/sh

# to-do: check OS version, add correct Directory Utility by location
#        check for directory binding and only add Directory Utility?

# check for dockutil, install via policy if not present

if [ ! -f "/usr/local/bin/dockutil" ]; then
    echo "Installing dockutil.."
    /usr/local/bin/jamf policy -trigger dockutil
    sleep 5
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "user"
if [ "$4" != "" ] ; then
	dpockutiluser=$4
elif
	user=$3
fi

# remove everything from the current user's Dock

/usr/local/bin/dockutil --remove all --no-restart /Users/$user/ ;

sleep 5;

/usr/local/bin/dockutil --add /Applications/Safari.app --position 1 --no-restart /Users/$user/ ;
/usr/local/bin/dockutil --add /Applications/Google\ Chrome.app --position 2 --no-restart /Users/$user/ ;
/usr/local/bin/dockutil --add /Applications/Utilities/Disk\ Utility.app --position 3 --no-restart /Users/$user/ ;
/usr/local/bin/dockutil --add /Applications/Utilities/Terminal.app --position 4 --no-restart /Users/$user/ ;
/usr/local/bin/dockutil --add /Applications/Utilities/Activity\ Monitor.app --position 5 --no-restart /Users/$user/ ;
/usr/local/bin/dockutil --add /System/Library/CoreServices/Applications/Directory\ Utility.app --position 6 /Users/$user/ ;
/usr/local/bin/dockutil --add /Applications/System\ Preferences.app --position 7 --no-restart /Users/$user/ ;
/usr/local/bin/dockutil --add /Applications/Self\ Service.app --position 8 --no-restart /Users/$user/ ;

# sudo -u $user /usr/bin/osascript -e 'tell application "Dock" to quit'
# makes more sense to have it in the script, but works better when called directly from the policy instead

exit 0

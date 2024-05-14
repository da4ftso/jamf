#!/bin/bash

autoload is-at-least
APP_NAME="Microsoft Teams (work or school)"

GetLoggedInUser() {
	LOGGEDIN=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/&&!/loginwindow/{print $3}')
	if [ "$LOGGEDIN" = "" ]; then
		echo "$USER"
	else
		echo "$LOGGEDIN"
	fi
}

SetHomeFolder() {
	HOME=$(dscl . read /Users/"$1" NFSHomeDirectory | cut -d ':' -f2 | cut -d ' ' -f2)
	if [ "$HOME" = "" ]; then
		if [ -d "/Users/$1" ]; then
			HOME="/Users/$1"
		else
			HOME=$(eval echo "~$1")
		fi
	fi
}


## Main
LoggedInUser=$(GetLoggedInUser)
SetHomeFolder "$LoggedInUser"
echo "Office-Reset: Running as: $LoggedInUser; Home Folder: $HOME"

kill -9 $(ps -ax | grep -iE "Microsoft Teams" | awk ' { print $1 }')

echo "Office-Reset: Removing configuration data for ${APP_NAME}"
/bin/rm -rf "$HOME/Library/Application Scripts/com.microsoft.teams2"
/bin/rm -rf "$HOME/Library/Application Scripts/com.microsoft.teams2.launcher"
/bin/rm -rf "$HOME/Library/Application Scripts/com.microsoft.teams2.notificationcenter"
/bin/rm -rf "$HOME/Library/Containers/Microsoft Teams (work or school)"
/bin/rm -rf "$HOME/Library/Containers/Microsoft Teams Launcher"
/bin/rm -rf "$HOME/Library/Containers/com.microsoft.teams2"
/bin/rm -rf "$HOME/Library/Containers/com.microsoft.teams2.notificationcenter"
/bin/rm -rf "$HOME/Library/Group Containers/UBF8T346G9.com.microsoft.oneauth"
/bin/rm -rf "$HOME/Library/Group Containers/UBF8T346G9.com.microsoft.teams"
/bin/rm -rf "$HOME/Library/Preferences/com.microsoft.teams2.helper.pliszt"
/bin/rm -rf "$HOME/Library/Saved Application State/com.microsoft.teams2.savedState"
/bin/rm -rf "$HOME/Library/Saved Application State/com.microsoft.teams2.savedState"

KeychainHasLogin=$(/usr/bin/sudo -u "$LoggedInUser" /usr/bin/security list-keychains | grep 'login.keychain')
if [ "$KeychainHasLogin" = "" ]; then
	echo "Office-Reset: Adding user login keychain to list"
	/usr/bin/sudo -u "$LoggedInUser" /usr/bin/security list-keychains -s "$HOME/Library/Keychains/login.keychain-db"
fi

echo "Display list-keychains for logged-in user"
/usr/bin/sudo -u "$LoggedInUser" /usr/bin/security list-keychains

/usr/bin/sudo -u "$LoggedInUser" /usr/bin/security delete-generic-password -l 'Microsoft Teams Identities Cache'
/usr/bin/sudo -u "$LoggedInUser" /usr/bin/security delete-generic-password -l 'Microsoft Teams Safe Storage'
/usr/bin/sudo -u "$LoggedInUser" /usr/bin/security delete-generic-password -l 'Teams Safe Storage'
/usr/bin/sudo -u "$LoggedInUser" /usr/bin/security delete-generic-password -l 'com.microsoft.teams.HockeySDK'
/usr/bin/sudo -u "$LoggedInUser" /usr/bin/security delete-generic-password -l 'com.microsoft.teams.helper.HockeySDK'

exit 0

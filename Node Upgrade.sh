#!/bin/bash

# 1.0 250428 brew upgrade node

loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
architectureCheck=$(/usr/bin/uname -m)
currentUserHome=$(dscl . read /Users/"${loggedInUser}" NFSHomeDirectory | cut -d: -f 2 | sed 's/^ *//'| tr -d '\n')

# brew node
if [ "$architectureCheck" = "arm64" ]; then
  brewPrefix="/opt/homebrew/bin"
else
  brewPrefix="/usr/local/bin"
fi

brewPath="$brewPrefix/brew"

# Check for presence of target binary and get version.
if [ -e "$brewPath" ]; then
	info=$(sudo -u "$loggedInUser" "$brewPath" info node)
	if [[ $info == *"Not installed"* ]]; then
		result=""
	else	
		sudo -u "$loggedInUser" "$brewPath" upgrade -f node
    	result="$( echo "$info" | awk '/node:/ { print $2 " " $3 " " $4;exit }' | tr -d '\r')"
    	result="${result//[!0-9.]/}" # bash only, if using zsh change this to sed
		echo "brew: $result"
		exit 0
	fi
fi


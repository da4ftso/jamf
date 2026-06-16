#!/bin/bash

# remove Anaconda Navagator (Distribution)
# https://www.anaconda.com/docs/getting-started/anaconda/uninstall

# variables

currentUser=$(/usr/bin/stat -f%Su "/dev/console")
currentUserHome=$(/usr/bin/dscl . -read "/Users/$currentUser" NFSHomeDirectory | /usr/bin/awk ' { print $NF } ')

if [[ -e "/Applications/Anaconda-Navigator.app" ]]; then
	echo "Removing /Applications/Anaconda-Navigator.app.."
    rm -rf "/Applications/Anaconda-Navigator.app"
fi

if [[ -e "$currentUserHome"/.anaconda ]]; then
	echo "Removing ~/anaconda3.."
    rm -rf "$currentUserHome"/.anaconda/
fi

if [[ -e /opt/anaconda3 ]]; then
	echo "Removing /opt/anaconda3.."
    rm -rf /opt/anaconda3/
fi

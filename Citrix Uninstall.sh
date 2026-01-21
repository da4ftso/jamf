#!/bin/sh

# created by BG 9/19/2022

# Define Location of Citrix Workspace
workspaceApp="/Applications/Citrix Workspace.app"

# If Citrix Receiver is installed, uninstall it
if [ -d "$workspaceApp" ]; then
    echo "Workspace installed, uninstalling"
    /private/tmp/Citrix/Uninstall\ Citrix\ Workspace.app/Contents/MacOS/Uninstall\ Citrix\ Workspace --nogui
    sleep 5
    uninstallerRunning=$(ps aux | grep "Uninstall Citrix Workspace" | grep -v "grep")
    while [ -e "$uninstallerRunning" ]; do
        echo "Uninstaller running"
        sleep 5
        uninstallerRunning=$(ps aux | grep "Uninstall Citrix Workspace" | grep -v "grep")
    done
    echo "Uninstaller not running"
    sleep 2
fi

# Delete folder created for Uninstall app
if [ -d /private/tmp/Citrix ]; then
  rm -rf /private/tmp/Citrix
fi

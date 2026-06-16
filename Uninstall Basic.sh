#!/bin/bash

# remove a single .app from /Applications.

# use "* App-Folder Uninstall" for anything that might also add to ~/Library or /Library

# variables

currentUser=$(stat -f %Su "/dev/console")
userHome=$(dscl . read "/Users/$currentUser" NFSHomeDirectory | awk ' { print $NF } ')

# param 4: app name

shopt -s nocasematch

if [ "$4" == "" ]; then
  echo "No app name specified, exiting.."
  exit 1
fi  

# app path
APP_NAME="$4"

# add /Applications prefix
if [[ "$APP_NAME" != /* ]]; then
  APP_NAME="/Applications/$APP_NAME"
fi

# add .app extension
if [[ "$APP_NAME" != *.app ]]; then
  APP_NAME="${APP_NAME}.app"
fi

# echo "Resolved app path: $APP_NAME"

# [trash] or delete

if [ "$5" == "" ] || [ "$5" == "Trash" ] ; then
 if [[ -e "$APP_NAME" ]]; then
   mv "$APP_NAME" "$userHome"/.Trash
   echo "Moved $APP_NAME to Trash..."
 fi
fi

if [ "$5" == "Delete" ] || [ "$5" == "rm" ] ; then
 if [[ -e "$APP_NAME" ]]; then
   rm -Rf "$APP_NAME"
   echo "Deleted $APP_NAME ..."
 fi
fi

shopt -u nocasematch


exit 0

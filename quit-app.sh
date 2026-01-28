#!/usr/bin/env bash

APPNAME="$4"

# Tests whether the app to be updated is closed - returns 1 if closed, or 0 if running
function is_app_closed()
{
    /usr/bin/pgrep -q "$APPNAME"
    /bin/echo "$?"
    return
}

# Attempt to gracefully close the app. If the document is dirty, the user will have 120 seconds to respond to the dialog before a timeout occurs
function gracefully_close_app()
{
    /usr/bin/osascript <<-EOD
        tell application "$APPNAME" to quit
    EOD
    sleep 5
}

# AppleScript to alert the user that the app needs to close
function show_update_alert()
{
    /usr/bin/osascript <<-EOD
    tell application "Finder"
        activate
        set DialogTitle to "Microsoft Office"     
        set DialogText to "Word will be updated in 60 seconds. Save all data, then click the 'Update Now' button."
        set DialogButton to "Update Now"
        set DialogIcon to "Applications:Microsoft Word.app:Contents:Resources:MSWD.icns"
        display dialog DialogText buttons {DialogButton} with title DialogTitle with icon file DialogIcon giving up after 60
    end tell
    EOD
}

# Send the app a signal to forcibly close the process
function forcibly_close_app()
{
    /usr/bin/pkill -HUP "$APPNAME"
}
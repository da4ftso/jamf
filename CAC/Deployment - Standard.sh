#!/bin/zsh -e -u -o PIPE_FAIL

# CAC

# 1.0 deployment - standard

# logging
startTime=$( /bin/date '+%s' ) # epoch time

# Define policies array
policies=(
    "Install_MSOffice365"
    "Install_Chrome"
    "install-drive"
    "install-acc"
    "install-rum"
    "Install_AdobeAcrobatReaderDCUpdates"
    "install-dockutil"
    "install-silnite"
)

# Execute all policies
for policy in "${policies[@]}"; do
    /usr/local/bin/jamf policy -event "$policy"
done

# TODO: Conditional policies
#    [CAC only: if Group == CAC, then...]
# fonts
# Xerox driver (Xerox options / configuration?)
# CAC branding
# MC branding
# script to apply user account images?
# Note: Zoom install currently commented out in original
# /usr/local/bin/jamf policy -event install-zoom

# end logging

stopTime=$( /bin/date '+%s' )
seconds=$(( $stopTime-$startTime ))
formattedTime=$( /bin/date -j -f "%s" "$seconds" '+%M minutes and %S seconds' )
echo "Elapsed time: $formattedTime"

exit 0

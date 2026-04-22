#!/bin/bash

# see Extension Attributes repo for a battery count EA

# Jamf Pro since ??? reports capacity and health, BUT
# needs to be up to date version of Pro to accurately return latest hw

hw=$(system_profiler SPHardwareDataType 2&>/dev/null | awk '/Model Name/ {print $3, $4}') # MacBook Pro

if [[ $hw == MacBook* ]]; then
	count=$(system_profiler SPPowerDataType | awk '/Cycle Count:/ { print $NF }')
    status=$(system_profiler SPPowerDataType | awk '/Condition:/ { print $NF; exit }')
else
	count=""
fi

echo "Cycle count:  $count"
echo "Health:       $status"

exit 0

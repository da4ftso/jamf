#!/bin/bash

# see Extension Attributes repo for a battery count EA

# Jamf Pro since ??? reports capacity and health, BUT
# needs to be up to date version of Pro to accurately return latest hw

# echo -e is bash only

#!/bin/bash

hw=$(system_profiler SPHardwareDataType | awk '/Model Name/ {print $3, $4}') # MacBook Pro

if [[ $hw == MacBook* ]]; then
	count=$(system_profiler SPPowerDataType | awk '/Cycle Count:/ { print $NF }')
    	echo -e "Cycles:\t\t$count"
	capacity=$(system_profiler SPPowerDataType | awk '/Maximum Capacity:/ { print $NF }')
    	echo -e "Capacity:\t$capacity"
    status=$(system_profiler SPPowerDataType | awk '/Condition:/ { print $NF; exit }')
		echo -e "Status:\t\t$status"
fi

exit 0

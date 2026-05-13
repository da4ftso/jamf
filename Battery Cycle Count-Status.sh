#!/bin/bash

# see Extension Attributes repo for a battery count EA
# https://github.com/da4ftso/Extension-Attributes/blob/master/HW%20-%20Battery%20Cycle%20Count.sh

# Jamf Pro since v? reports capacity and health, but needs to 
# be up-to-date version of Pro to accurately report latest HW

# echo -e is bash only

#!/bin/bash

hw=$(system_profiler SPHardwareDataType | awk '/Model Name/ {print $3, $4}') # MacBook Pro

if [[ $hw == MacBook* ]]; then
	power_data=$(system_profiler SPPowerDataType)
	count=$(echo "$power_data" | awk '/Cycle Count:/ { print $NF }')
    	echo -e "Cycles:\t\t$count"
	capacity=$(echo "$power_data" | awk '/Maximum Capacity:/ { print $NF }')
    	echo -e "Capacity:\t$capacity"
    status=$(echo "$power_data" | awk '/Condition:/ { print $NF; exit }')
		echo -e "Status:\t\t$status"
fi

exit 0

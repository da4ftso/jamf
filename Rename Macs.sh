#!/bin/bash

# Since 2022, Macs no longer contain "Book," "Pro," or "i" in their ModelIDs.

#  Mac Studio (M1 Max, 2022):				Mac13,1
#  Mac Studio (M1 Ultra, 2022):				Mac13,2
#  MacBook Air (M2, 2022):				Mac14,2
#  Mac mini (M2, 2023):					Mac14,3
#  MacBook Pro (14", M2 Max, 2023): 			Mac14,5
#  MacBook Pro (16", M2 Max, 2023): 			Mac14,6
#  MacBook Pro (13", M2):				Mac14,7
#  Mac Pro (2023):					Mac14,8
#  MacBook Pro (14", 2023): 				Mac14,9
#  MacBook Pro (16", M2 Pro, 2023): 			Mac14,10
#  Mac mini (M2 Pro, 2023):				Mac14,12
#  Mac Studio (M2 Max, 2023):				Mac14,13
#  Mac Studio (M2 Ultra, 2023):				Mac14,14
#  MacBook Air (15-inch, M2, 2023):			Mac14,15

# to put it another way, you can't rely upon "Book" being anywhere in ioreg anymore
# https://support.apple.com/en-us/HT201300

serial="$(ioreg -l | grep IOPlatformSerialNumber | sed -e 's/.*\"\(.*\)\"/\1/')"
Battery=$(ioreg -c AppleSmartBattery -r | awk '/BatteryInstalled/ { print $3 }') # Yes if portable, No or blank for desktop

if [[ $Battery == "Yes" ]]; then
	ADCOMPUTERNAME="L"$serial
else
	ADCOMPUTERNAME="D"$serial
fi

# Set Hostname using variable created above
scutil --set HostName $ADCOMPUTERNAME
scutil --set LocalHostName $ADCOMPUTERNAME
scutil --set ComputerName $ADCOMPUTERNAME

echo "Set device to $ADCOMPUTERNAME"

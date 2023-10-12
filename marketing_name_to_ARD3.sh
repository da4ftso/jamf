#!/bin/bash

# Location of file containing "marketing" names
marketingData=/System/Library/PrivateFrameworks/ServerInformation.framework/Versions/A/Resources/English.lproj/SIMachineAttributes.plist

# Find the model ID (ie "MacPro4,1")
modelID="$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep Ident | /usr/bin/cut -d":" -f2 | cut -d" " -f2)"
if /bin/test $? -ne 0
then
	modelID="_noModel_"
	dataError=true
fi

# Using model ID, find "marketing name" (ie "Mac Pro Early 2009")
# This info is not consistent within Apple itself and is used for informational purposes only.
marketingID="$(/usr/libexec/PlistBuddy -c "Print $modelID" $marketingData | /usr/bin/grep "marketing" | /usr/bin/cut -d"=" -f2 | /usr/bin/cut -d" " -f2-)"
if /bin/test $? -ne 0
then
	marketingID="_noMarket_"
	dataError=true
fi

/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -computerinfo -set3 -3 "$marketingID"

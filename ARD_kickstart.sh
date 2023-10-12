#!/bin/sh

# original version was simply
# /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users admin -privs -all -restart -agent -menu

#!/bin/sh

/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -activate -configure -clientopts -setmenuextra -menuextra yes 
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -configure -users admin -access -on -privs -all
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -configure -allowAccessFor -specifiedUsers -privs -all
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -restart -agent -menu

/usr/sbin/systemsetup -setremotelogin on

exit 0

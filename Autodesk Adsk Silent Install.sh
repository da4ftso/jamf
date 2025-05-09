#!/bin/bash

# remember to set .dmg to Cache
# remember to run script as After

# variables
dmg="/Library/Application Support/JAMF/Waiting Room/AdskIdentityManager-1.15.3.dmg"
volume_name="Installer"

# mount the DMG
if [[ -f "${dmg}" ]]; then
	echo "Installer .DMG found, proceeding.."
    hdiutil attach -nobrowse "${dmg}"
else
	echo "Installer .DMG not found, exiting.."
    exit 1
fi    

# kill the installer
/usr/bin/pkill "Installer"

# silent install
echo "Beginning installation of Autodesk Identity Manager..."
/Volumes/Installer/Install_Autodesk_Identity_Manager.app/Contents/MacOS/Setup --silent 2>/dev/null ; 

# let installer complete
sleep 5

# cleanup
force_unmount() {
    local max_attempts=3 # local only valid inside function
    local attempt=1

    echo "Attempting to unmount volume: $volume_name"

    while mount | grep -q "/Volumes/$volume_name"; do
        # echo "Attempt $attempt: Trying to unmount /Volumes/$volume_name..."
        diskutil unmount "/Volumes/$volume_name" >/dev/null 2>&1

        # again!
        sleep 2

        if ! mount | grep -q "/Volumes/$volume_name"; then
            echo "Volume '$volume_name' successfully unmounted."
            return 0
        fi

        ((attempt++))
        if [ $attempt -gt $max_attempts ]; then
            echo "❌ Failed to unmount volume '$volume_name' after $max_attempts attempts."
            return 1
        fi
    done

    echo "Volume '$volume_name' was already unmounted."
    return 0
}

force_unmount
exit 0

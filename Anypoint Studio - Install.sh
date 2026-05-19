#!/usr/bin/env bash

# Script to install Anypoint Studio from a cached DMG located in JAMF's Waiting Room.

# Variables
WAITING_ROOM="/Library/Application Support/JAMF/Waiting Room"
currentUser=$(stat -f%Su /dev/console)

# Determine the DMG filename
if [[ -z "$4" ]]; then
    # No parameter provided, search for a .DMG file in the Waiting Room
    echo "No DMG filename provided as parameter $4. Searching for .DMG files in Waiting Room..."
    DMG=$(find "${WAITING_ROOM}" -maxdepth 1 -type f -name "*.DMG" -o -name "*.dmg" | head -n 1)
    
    if [[ -z "$DMG" ]]; then
        echo "Error: No .DMG file found in '${WAITING_ROOM}'. Exiting..." >&2
        exit 1
    fi
    echo "Found DMG file: ${DMG}"
else
    # Use the provided parameter
    DMG="${WAITING_ROOM}/${4}"
fi

# Ensure the DMG file exists before proceeding.
if [[ ! -f "${DMG}" ]]; then
    echo "Error: DMG file '${DMG}' not found. Exiting..." >&2
    exit 1
fi

# Mount the DMG
mountPoint=$(hdiutil attach "${DMG}" -nobrowse | grep Volumes | awk '{$1=$2=""; print $0}' | xargs)
if [[ -z "$mountPoint" ]]; then
    echo "Error: Failed to mount the DMG '${DMG}'. Exiting..." >&2
    exit 1
fi

# Log the successful mount point
echo "Mounted DMG at: ${mountPoint}"

# Install the application using 'rsync' for reliability.
rsync -avhPrq "${mountPoint}/AnypointStudio.app" /Applications/
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to copy Anypoint Studio to /Applications. Exiting..." >&2
    hdiutil detach "${mountPoint}" # Attempt to safely unmount the DMG
    exit 1
fi

# Change ownership of the application to the current user.
chown -R "${currentUser}" /Applications/AnypointStudio.app || echo "Warning: Failed to set ownership."

# Unmount the DMG.
hdiutil detach "${mountPoint}" || echo "Warning: Failed to unmount the DMG."

# Remove the cached DMG file.
rm -f "${DMG}"*

echo "Installation of Anypoint Studio completed successfully."

#!/usr/bin/env bash

# The Adsk tool will return some contradictory info:
#
# /Library/Application\ Support/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list
#    "feature_id": "ACDLTM",
#    "def_prod_key": "827P1",
#    "def_prod_ver": "2024.0.0.F",
# [...]
#    "feature_id": "ACDLTM",
#     "def_prod_key": "827Q1",
#     "def_prod_ver": "2025.0.0.F",
#
# However, when we check here: https://www.autodesk.com/support/download-install/admins/keys/look-up-product-keys
#
# The product key for AutoCAD LT for Mac 2025 is:
# 827Q1

# variables

user=$(stat -f %Su /dev/console)
userHome=$(/usr/bin/dscl . -read "/Users/$user" NFSHomeDirectory | /usr/bin/awk ' { print $NF } ')

DMG="/Library/Application Support/JAMF/Waiting Room/Autodesk_AutoCAD_LT_2025.1_macOS.dmg"

# mount the DMG
if [[ -z "$DMG" ]]; then
	echo "Installer .DMG not found, exiting.."
    exit 1
else
	echo "Installer .DMG found, proceeding.."
    hdiutil attach -nobrowse "$DMG"
fi    

# kill the installer

/usr/bin/pkill "Installer"

# silent install

echo "Beginning installation of AutoCAD LT 2025..."
sudo /Volumes/Installer/Install\ Autodesk\ AutoCAD\ LT\ 2025\ for\ Mac.app/Contents/Helper/Setup.app/Contents/MacOS/Setup --silent

# let installer complete

sleep 10

# activation

/Library/Application\ Support/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper change --prod_key 827Q1 --prod_ver 2025.0.0.F --lic_method USER

# add to current user's dock

# echo "Adding 2025 to current user's dock..."
# /usr/local/bin/dockutil --add /Applications/Autodesk/AutoCAD\ LT\ 2025/AutoCAD\ LT\ 2025.app --replacing 'AutoCAD LT 2024' "$userHome"
# /usr/local/bin/dockutil --remove /Applications/Autodesk/AutoCAD\ LT\ 2024/AutoCAD\ LT\ 2024.app --position end "$userHome"

# cleanup

echo "Unmounting installer..."
hdiutil detach "/Volumes/Installer"
echo "Removing installer..."
rm -rf "$DMG"

exit 0

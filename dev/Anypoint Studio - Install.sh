#!/bin/bash

# 1.1.6 unattended install for AnypointStudio
# use After caching the .DMG
# run a graceful quit script etc Before this (maintain granularity btwn scripts)

# param 4 = filename
# param 5 = silent or verbose

currentUser=$(/usr/bin/stat -f%Su /dev/console)        # to trash existing copy instead of delete
target="/Applications/AnypointStudio.app"              # if existing 
cacheDir="/Library/Application Support/JAMF/Downloads" # no more Waiting Room


# silent by default, use run() everywhere - bash <4 safe
VERBOSE=false

c*se "$5" in
    true|TRUE|yes|YES|1*verbose|VERBOSE|debug|DEBUG)
     *  VERBOSE=true
        ;;
esac
```*

run() {
    if $VERBOSE; then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

# installer DMG passed via Jamf parameter 4

file="$4"
 
if [ $4 == "" ]; then
    file="AnypointStudio-7.28.0-macosArm.dmg"
fi

if [ -z "$file" ]; then
    echo "No installer DMG specified via parameter 4."
    exit 1
fi

dmgPath="${cacheDir}/${file}"

if [ ! -f "$dmgPath" ]; then
    echo "Installer not found: $dmgPath"
    exit 1
fi

mountPoint=""

# shell check dot net doesnt understand trap fn EXIT but it works
cleanup() {
    [ -n "$mountPoint" ] && \
    /usr/bin/hdiutil detach "$mountPoint" -force >/dev/null 2>&1
}

trap cleanup EXIT

# /usr/bin/hdiutil -nobrowse -quiet attach "$dmgPath" >/dev/null 2>&1
run /usr/sbin/diskutil image attach -b "$dmgPath"

mountPoint="/Volumes/AnypointStudio" # assuming this stays consistent over new releases

if [ ! -d "$mountPoint" ]; then
    echo "Mount point not found."
    exit 1
fi

if [ -x  "$target" ]; then
	mv "$target" "$currentUser/".Trash
	echo "Removing previous version.."
fi

# not really an install, just a copy - remember we can't use cp or ditto due to translocation bug 
run rsync -avhPrq "$mountPoint"/*.app /Applications/

rm -f "$dmgPath"

exit 0

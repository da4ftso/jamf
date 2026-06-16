#!/bin/bash
# set env pipefail here?

# variables

lastUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }' )
currentUser=$(/usr/bin/stat -f%Su "/dev/console")
userHome=$(/usr/bin/dscl . -read "/Users/$currentUser" NFSHomeDirectory | /usr/bin/awk ' { print $NF } ')

if [ "$currentUser" == "" ] || [ "$currentUser" == "root" ]; then
 userHome=$(/usr/bin/dscl . -read "/Users/$lastUser" NFSHomeDirectory | /usr/bin/awk ' { print $NF } ')
fi

# Remove files and directories
files_to_remove=(
	"/Applications/APPNAME.app"
	"$userHome/Library/Application Support/FOLDER1/"
	"$userHome/Library/Caches/FOLDER2/"
)

for f in "${files_to_remove[@]}"; do
	if [[ -e "$f" ]]; then
		echo "Deleting: $f"
		rm -Rf "$f"
	fi
done

echo "Uninstall complete."
exit 0

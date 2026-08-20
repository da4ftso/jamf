#!/usr/bin/env bash

# set DBeaver pref to disable usage collection
# even though DBeaver publishes their policy and claim to anonymize all data
# some orgs may need to disable this setting

currentUser=$( /usr/bin/stat -f%Su "/dev/console" )
currentUserHome=$(/usr/bin/dscl . -read "/Users/$currentUser" NFSHomeDirectory | /usr/bin/awk ' { print $NF } ')

prefs="${currentUserHome}"/Library/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.ui.statistics.prefs

if [[ -e "${prefs}" ]]; then

	/usr/bin/sed -i '' 's/enabled=true/enabled=false/' "${prefs}"
    
fi

#!/bin/bash

# this is a (very old) basic version without any jamf params for options - for a more robust version, try:
# https://github.com/cocopuff2u/MOFA/blob/main/office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_Office_Removal.zsh

# minor edits based on shellcheck and better $user checking

consoleuser=$(stat -f %Su /dev/console);

echo "logged in user is" "$consoleuser"

pkill -f Microsoft

folders=(
"/Applications/Microsoft Excel.app"
"/Applications/Microsoft OneNote.app"
"/Applications/Microsoft Outlook.app"
"/Applications/Microsoft PowerPoint.app"
"/Applications/Microsoft Word.app" )

#
"/Users/$consoleuser/Library/Containers/com.microsoft.errorreporting"
"/Users/$consoleuser/Library/Containers/com.microsoft.Excel"
"/Users/$consoleuser/Library/Containers/com.microsoft.netlib.shipassertprocess"
"/Users/$consoleuser/Library/Containers/com.microsoft.Office365ServiceV2"
"/Users/$consoleuser/Library/Containers/com.microsoft.Outlook"
"/Users/$consoleuser/Library/Containers/com.microsoft.Powerpoint"
"/Users/$consoleuser/Library/Containers/com.microsoft.RMS-XPCService"
"/Users/$consoleuser/Library/Containers/com.microsoft.Word"
"/Users/$consoleuser/Library/Containers/com.microsoft.onenote.mac"
#
#
#### WARNING: Outlook data will be removed when you move the three folders listed below.
#### You should back up these folders before you delete them.
#"/Users/$consoleuser/Library/Group Containers/UBF8T346G9.ms"
#"/Users/$consoleuser/Library/Group Containers/UBF8T346G9.Office"
#"/Users/$consoleuser/Library/Group Containers/UBF8T346G9.OfficeOsfWebHost"
#)

search="*"

for i in "${folders[@]}";

do
    echo "removing folder ${i}"
    rm -rf "${i}";

done

if [ $? == 0 ]; then
     echo "Success"
else
     echo "Failure"
fi

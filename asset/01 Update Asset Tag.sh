#!/bin/bash
set -euo pipefail

# 2.0 260216
# since we don't want to leave API creds on an endpoint,
# we're still going to rely on recon
#
# this prompts the user and writes to some temp files
#
# then script 02 passes the values from those files to
# jamf recon, then cleans them up

# osascript
#  prompt for username and assetTag and building in a single window

answers=$(/usr/bin/osascript <<'APPLESCRIPT'
use framework "AppKit"
use scripting additions

on run
  set buildingList to {"Albuquerque HQ - NM", ¬
    "Chicago HQ - IL", ¬
    "Chicago Pilsen - IL", ¬
    "Cigna", ¬
    "Dallas C1 - TX", ¬
    "Danville - IL", ¬
    "Downers Grove - IL", ¬
    "Helena HQ - MT", ¬
    "Houston - TX", ¬
    "Lombard - IL", ¬
    "Mattoon - IL", ¬
    "Morgan Park - IL", ¬
    "Mural Park - IL", ¬
    "Naperville - IL", ¬
    "Offshore", ¬
    "Pullman - IL", ¬
    "Quincy - IL", ¬
    "Richardson HQ - TX", ¬
    "Rockford - IL", ¬
    "South Lawndale - IL", ¬
    "Southfield - MI", ¬
    "Springfield - IL", ¬
    "Tulsa HQ - OK", ¬
    "Waco - TX", ¬
    "Washington, DC", ¬
    "Waukegan - IL"}

  set theTitle to "Asset Registration"

  -- Create text fields and popup using AppKit
  set fieldWidth to 360
  set fieldHeight to 24
  set padding to 8

  set usernameField to current application's NSTextField's alloc()'s initWithFrame:(current application's NSMakeRect(0, 64, fieldWidth, fieldHeight))
  usernameField's setPlaceholderString:"Username"
  usernameField's setStringValue:""

  set assetField to current application's NSTextField's alloc()'s initWithFrame:(current application's NSMakeRect(0, 32, fieldWidth, fieldHeight))
  assetField's setPlaceholderString:"Asset tag"
  assetField's setStringValue:""

  set buildingPop to current application's NSPopUpButton's alloc()'s initWithFrame:(current application's NSMakeRect(0, 0, fieldWidth, 26)) pullsDown:false
  buildingPop's addItemsWithTitles:buildingList
  -- default to "Chicago HQ - IL" if present
  try
    buildingPop's selectItemWithTitle:"Chicago HQ - IL"
  end try

  set accessoryHeight to 64 + fieldHeight + padding
  set accessoryView to current application's NSView's alloc()'s initWithFrame:(current application's NSMakeRect(0, 0, fieldWidth, accessoryHeight))
  accessoryView's addSubview:usernameField
  accessoryView's addSubview:assetField
  accessoryView's addSubview:buildingPop

  set theAlert to current application's NSAlert's alloc()'s init()
  theAlert's setMessageText:theTitle
  theAlert's setInformativeText:"Enter username, asset tag, and choose a building."
  theAlert's setAccessoryView:accessoryView
  theAlert's addButtonWithTitle:"OK"
  theAlert's addButtonWithTitle:"Cancel"

  set response to theAlert's runModal()
  if response is equal to (current application's NSAlertSecondButtonReturn) then
    return "__CANCELED__"
  end if

  set uname to (usernameField's stringValue()) as text
  set atag to (assetField's stringValue()) as text
  set bldg to (buildingPop's titleOfSelectedItem()) as text

  -- Return as tab-delimited so bash can split.
  return uname & tab & atag & tab & bldg
end run
APPLESCRIPT
)

if [[ "$answers" == "__CANCELED__" ]]; then
  echo "User canceled. No files written." >&2
  exit 0
fi

# $answers to separate variables
IFS=$'\t' read -r username assetTag building <<< "$answers"

# write temp files
printf '%s\n' "$username"  > "/tmp/.username.txt"
printf '%s\n' "$assetTag"  > "/tmp/.assetTag.txt"
printf '%s\n' "$building"  > "/tmp/.building.txt"

# single combined output left here, but faster to cat each tmpfile than awk for each field
# cat > "$tmpdir/asset_info.env" <<EOF
# username=$username
# assetTag=$assetTag
# building=$building
# EOF

# echo "Wrote temp files to: $tmpdir"
# echo " - /tmp/.username.txt"
# echo " - /tmp/.assetTag.txt"
# echo " - /tmp/.building.txt"
# echo " - /tmp/.asset_info.env"

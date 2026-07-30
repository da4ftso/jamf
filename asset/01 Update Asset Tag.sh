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
#  prompt for username and assetTag
#  choose from Building list

answers=$(/usr/bin/osascript <<'APPLESCRIPT'
on promptField(thePrompt, theDefault, theTitle)
  try
    display dialog thePrompt default answer theDefault with title theTitle buttons {"Cancel", "OK"} default button "OK"
    return text returned of result
  on error number -128
    -- user canceled
    return "__CANCELED__"
  end try
end promptField

on chooseBuilding(theTitle)
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

  try
    set choice to choose from list buildingList with title theTitle with prompt "Choose a building:" default items {"Chicago HQ - IL"} without multiple selections allowed
    if choice is false then return "__CANCELED__"
    return item 1 of choice
  on error number -128
    return "__CANCELED__"
  end try
end chooseBuilding

set theTitle to "Asset Registration"

set u to promptField("Enter username:", "", theTitle)
if u is "__CANCELED__" then return "__CANCELED__"

set a to promptField("Enter asset tag:", "", theTitle)
if a is "__CANCELED__" then return "__CANCELED__"

set b to chooseBuilding(theTitle)
if b is "__CANCELED__" then return "__CANCELED__"

-- Return as tab-delimited so bash can split.
return u & tab & a & tab & b
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

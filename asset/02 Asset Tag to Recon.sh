#!/bin/bash
set -euo pipefail

# 2.0 260216

# since we don't want to leave API creds on an endpoint,
# we're still going to rely on recon
#
# but this way we're only calling recon at the end with
# a separate script, runs last in 001 Deploy Standard

# read values set by 00 - Update Asset Tag and 
# pass to 'jamf recon'

# faster than awk'ing from a combined file
jamf recon \
-assetTag "$(cat /tmp/.assetTag.txt)" \
-endUsername "$(cat /tmp/.username.txt)" \
-building "$(cat /tmp/.building.txt)"

# cleanup

files=(
 /tmp/.assetTag.txt
 /tmp/.username.txt
 /tmp/.building.txt
 /tmp/asset_info.env
)

for i in "${files[@]}"; do
	if [[ -e "$i" ]]; then
    	rm -f "$i"
    fi
done    

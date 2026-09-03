#!/bin/bash

# EdgeUpdater-Cleanup-1.0.1
# 250402

# a few builds of Edge left huge tmp files buried in /Library
# you probably don't need thius anymore either

updateDir="/Library/Application Support/Microsoft/EdgeUpdater/apps"

if [[ -d "${updateDir}" ]]; then
        space=$(du -h "${updateDir}" | awk 'END { print $1 } ')
        rm -rf "${updateDir:?}"/*
        echo "Removed ""$space"" of old updates.."
fi

exit

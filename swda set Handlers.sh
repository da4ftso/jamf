#!/bin/bash

# swda Outlook Handlers
# https://github.com/Lord-Kamina/SwiftDefaultApps

# TO-DO
# param to select app
# param to reset to defaults

# set Outlook as handlers

if [ -e "/Applications/Microsoft Outlook.app" ]; then
  /usr/local/bin/swda setHandler --app "/Applications/Microsoft Outlook.app" --mail
  echo "Outlook set as handler for mail:"
  /usr/local/bin/swda setHandler --app "/Applications/Microsoft Outlook.app" --URL webcal
  echo "Outlook set as handler for webcal:"
else
  echo "Microsoft Outlook not found, exiting.."
  exit 1
fi  

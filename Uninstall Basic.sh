#!/bin/bash

if [ "$4" == "" ]; then
  echo "No app name specified, exiting.."
  exit 1
fi  

# Remove files and directories
if [[ -e "$4" ]]; then
	echo "Deleting: $4"
	rm -Rf "$4"
fi

# echo "Uninstall complete."
exit 0

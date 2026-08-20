#!/bin/bash

# 1.0 uninstall Workbrew 
# https://workbrew.com/docs/decommission-a-device-or-move-it-to-another-workspace

# default output says /opt/workbrew/home will not be deleted, but it gets deleted
# in fact all of /opt/workbrew/ is deleted (as per the docs)

if [[ -x /opt/workbrew/sbin/uninstall ]]; then

  /opt/workbrew/sbin/uninstall &>/dev/null

else

  echo "Unable to run Workbrew uninstall, exiting.."
  exit 1

fi

if [[ -e /Applications/Workbrew.app ]]; then

  rm -Rf /Applications/Workbrew.app
  # echo "Workbrew.app removed.."

fi  

exit

#!/bin/bash

# Quit All Apps 1.0.1
#
# Use this as a Before script for a 'big red button' one-click approach to updating apps.
#
# The 'app_mode_loader' appears to be a component of Google Chrome that is active if you're using a PWA.
# 
# You should be careful with Cisco AnyConnect / Secure Client or similar network clients.
# Remove the Script Editor once you're done fine-tuning.

osascript -e 'tell application "System Events" to set quitapps to name of every application process whose visible is true and name is not "Finder" and name is not "Cisco Secure Client" and name is not "Script Editor"
repeat with closeall in quitapps
	quit application closeall
	delay 10
end repeat'

exit

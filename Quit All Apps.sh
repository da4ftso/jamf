#!/bin/bash

# Quit All Apps 1.0.1
#
# Use this as a Before script for a 'big red button' one-click approach to updating apps.
#
# The 'app_mode_loader' appears to be a component of Google Chrome that is active if you're using a PWA.
# 
# You should be careful with Cisco AnyConnect / Secure Client or similar network clients.

osascript -e 'tell application "System Events" to set visible of (processes whose background only is false and visible is false) to true'

sleep 3

osascript -e 'tell application "Google Chrome" to quit'

osascript -e 'tell application "System Events" to set quitapps to name of every application process whose visible is true and name is not "Finder" and name is not "app_mode_loader" and name is not "Cisco Secure Client"
    repeat with closeall in quitapps
    quit application closeall
end repeat'

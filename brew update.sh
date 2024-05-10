#!/bin/bash

# variables

# current user
consoleuser="$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )"

# arch
UNAME_MACHINE="$(uname -m)"

# Set the prefix based on the machine type
if [[ "$UNAME_MACHINE" == "arm64" ]]; then
    # M1/arm64 machines
    HOMEBREW_PREFIX="/opt/homebrew"
else
    # Intel machines
    HOMEBREW_PREFIX="/usr/local"
fi

# logging
LOGFOLDER="/private/var/log/"
LOG="${LOGFOLDER}Homebrew.log"

if [ ! -d "$LOGFOLDER" ]; then
    mkdir $LOGFOLDER
fi

cac4=/opt/cisco/anyconnect/bin/vpn
cac5=/opt/cisco/secureclient/bin/vpn

# check for VPN connection
if [[ -e $cac4 ]]; then
	vpnstatus=$($cac4 state | awk '/state:/ { print $NF; exit } ')
elif [[ -e $cac5 ]]; then
	vpnstatus=$($cac5 state | awk '/state:/ { print $NF; exit } ')
fi    

if [[ "$vpnstatus" = "Connected" ]]; then

	echo "VPN connected, exiting.."
	exit 0
	
fi

# check if we can reach the source
ping -c 1 github.com
rc=$?

if [[ $rc -eq 0 ]]; then

	su -l "$consoleuser" -c "${HOMEBREW_PREFIX}/bin/brew update" 2>&1 | tee -a ${LOG}
    
else

	echo "Cannot reach github.com, exiting.. "

fi

exit 0

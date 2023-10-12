#!/bin/bash

# Checks to see if the Mac is either a MacBook, MacBook Pro Retina or MacBook Air.
# If it's any of these machines, the script will then check for external USB
# or Thunderbolt network adapters. If an adapter is present, it will add the 
# adapter to network services.
#
# Original script by Allen Golbig:
# https://github.com/golbiga/Scripts/tree/master/enable_external_network_adapter
# REF https://github.com/rtrouton/rtrouton_scripts/tree/master/rtrouton_scripts/enable_external_network_adapter
# Modified: 2017-01-27 to included USB-C adapters from Belkin and Startech - Jhalvorson


##########################################################################################
# Create time date stamped log to record actions taken by this script.
##########################################################################################
logFile="/private/var/log/companynamehereInfoTech.log"

log () {
    /bin/echo $1
    /bin/echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $logFile 
}

log "-----"
log "Begin 010_Network_enable_external_adapters.sh"

macbook_check=`/usr/sbin/system_profiler SPHardwareDataType | awk '/Model Name/' | awk -F': ' '{print substr($2,1,7)}'`

usbcstartechus1fc30a=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: USB 10/100/1000 LAN"`
usbcbelkinf2cu040=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: Belkin USB-C LAN"`

usbGigAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: USB Gigabit Ethernet"`
usbAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: USB Ethernet"`
usbAppleAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: Apple USB Ethernet Adapter"`

tbAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: Thunderbolt Ethernet"`
tbDisplay=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: Display Ethernet"`

/usr/sbin/networksetup -detectnewhardware

if [ "$macbook_check" = "MacBook" ]; then
    if [ "$usbcstartechus1fc30a" != "" ]; then
        /usr/sbin/networksetup -createnetworkservice USB\ 10/100/1000\ LAN 'USB 10/100/1000 LAN'
        log "-"
        log "USB-C StarTech us1fc30a added to Network Services"
        log "-"
    else
        log "No USB-C Startech connected"
    fi
        if [ "$usbcbelkinf2cu040" != "" ]; then
        /usr/sbin/networksetup -createnetworkservice Belkin\ USB-C\ LAN 'Belkin USB-C LAN'
        log "-"
        log "USB-C Belkin 2cu040 added to Network Services"
        log "-"
    else
        log "No USB-C Belkin connected"
    fi
    if [ "$usbAdapter" != "" ]; then
        /usr/sbin/networksetup -createnetworkservice USB\ Ethernet 'USB Ethernet'
        log "-"
        log "USB Ethernet added to Network Services"
        log "-"
    else
        log "No USB Adapter connected"
    fi
    if [ "$usbAdapter" != "" ]; then
        /usr/sbin/networksetup -createnetworkservice Apple\ USB\ Ethernet\ Adapter 'Apple USB Ethernet Adapter'
        log "-"
        log "Apple USB Ethernet Adapter added to Network Services"
        log "-"
    else
        log "No Apple USB Ethernet Adapter connected"
    fi
    if [ "$usbGigAdapter" != "" ]; then
        /usr/sbin/networksetup -createnetworkservice USB\ Gigabit\ Ethernet 'USB Gigabit Ethernet'
        log "-"
        log "USB Gigabit Ethernet Adapter added to Network Services"
        log "-"
    else
        log "No USB Gigabit Ethernet Adapter connected"
    fi
    if [ "$tbAdapter" != "" ]; then
        /usr/sbin/networksetup -createnetworkservice Thunderbolt\ Ethernet 'Thunderbolt Ethernet'
        log "-"
        log "Thunderbolt Ethernet added to Network Services"
        log "-"
    else
        log "No Thunderbolt Adapter connected"
    fi
    if [ "$tbDisplay" != "" ]; then
        /usr/sbin/networksetup -createnetworkservice Display\ Ethernet 'Display Ethernet'
        log "-"
        log "Display Ethernet added to Network Services"
        log "-"
    else
        log "No Display Ethernet connected"
    fi
else
    log "-----"
    log "This machine does not use external network adapters"
    log "-----"
fi

log "Completed 010_Network_enable_external_adapters.sh"

exit 0

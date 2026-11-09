#!/usr/bin/env bash

# 1.6 better user check

export HOMEBREW_NO_ENV_HINTS=1

# console user; fall back to last logged-in user if at loginwindow
consoleuser=$(
    echo "show State:/Users/ConsoleUser" | scutil |
    awk '/Name :/ { print $3 }'
)

if [[ -z "$consoleuser" || "$consoleuser" == "loginwindow" || "$consoleuser" == "root" ]]; then
    consoleuser=$(
        defaults read /Library/Preferences/com.apple.loginwindow lastUserName 2>/dev/null
    )
fi

# No usable user account found
if [[ -z "$consoleuser" || "$consoleuser" == "loginwindow" || "$consoleuser" == "root" ]]; then
    exit 0
fi

# Homebrew prefix
if [[ "$(uname -m)" == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
else
    HOMEBREW_PREFIX="/usr/local"
fi

BREW="${HOMEBREW_PREFIX}/bin/brew"

# Cisco VPN paths
cac4="/opt/cisco/anyconnect/bin/vpn"
cac5="/opt/cisco/secureclient/bin/vpn"

# Check VPN status
vpnstatus=""

if [[ -x "$cac4" ]]; then
    vpnstatus=$("$cac4" state 2>/dev/null | awk '/state:/ {print $NF; exit}')
elif [[ -x "$cac5" ]]; then
    vpnstatus=$("$cac5" state 2>/dev/null | awk '/state:/ {print $NF; exit}')
fi

if [[ "$vpnstatus" == "Connected" ]]; then
    exit 0
fi

# GH reachable?
if ping -c 1 -t 1 github.com >/dev/null 2>&1; then
    su -l "$consoleuser" -c "$BREW update >/dev/null 2>&1"
fi

# upgrade -> output
upgrade_output=$(
    su -l "$consoleuser" -c \
    "$BREW upgrade --force --greedy 2>&1"
)

# show only actually upgraded items
echo "$upgrade_output" | awk '/^==> Upgrading /'

# cleanup
su -l "$consoleuser" -c \
    "$BREW cleanup >/dev/null 2>&1"

exit 0
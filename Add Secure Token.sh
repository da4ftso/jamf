#!/bin/sh

# TO-DO:
#  add (working) Cancel buttons 
#  pre-populate hasToken account names with results from dscl
#  pre-populate getToken account name by diff'ing diskutil vs dscl ?

# based on Hexnode's but adding osascript to capture all u/p

hasToken="$(osascript -e 'Tell current application to display dialog "Admin account:" default answer "administrator" with text buttons {"OK"} default button "OK" ' \
-e 'text returned of result')"

hasTokenPassword="$(osascript -e 'Tell current application to display dialog "Admin password:" default answer "" with text buttons {"OK"} default button "OK" with hidden answer' \
-e 'text returned of result')"

getToken="$(osascript -e 'Tell current application to display dialog "User account:" default answer "" with text buttons {"OK"} default button "OK" ' \
-e 'text returned of result')"

getTokenPassword="$(osascript -e 'Tell current application to display dialog "User password:" default answer "" with text buttons {"OK"} default button "OK" with hidden answer' \
-e 'text returned of result')"

macOSVersionMajor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F . '{print $1}')
macOSVersionMinor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F . '{print $2}')
macOSVersionBuild=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F . '{print $3}')

# exits if macOS version predates the use of SecureToken functionality
check_macos_version () {
  # exit if macOS < 10
  if [ "$macOSVersionMajor" -lt 10 ]; then
    echo "macOS version ${macOSVersionMajor} predates the use of SecureToken functionality, no action required."
    exit 0
  # exit if macOS 10 < 10.13.4
  elif [ "$macOSVersionMajor" -eq 10 ]; then
    if [ "$macOSVersionMinor" -lt 13 ]; then
      echo "macOS version ${macOSVersionMajor}.${macOSVersionMinor} predates the use of SecureToken functionality, no action required."
      exit 0
    elif [ "$macOSVersionMinor" -eq 13 ] && [ "$macOSVersionBuild" -lt 4 ]; then
      echo "macOS version ${macOSVersionMajor}.${macOSVersionMinor}.${macOSVersionBuild} predates the use of SecureToken functionality, no action required."
      exit 0
    fi
  fi
}

# exits if $getToken already has one
check_securetoken_user () {
  if /usr/sbin/sysadminctl -secureTokenStatus "$getToken" 2>&1 | /usr/bin/grep -q "ENABLED"; then
    echo "${getToken} already has a SecureToken. No action required."
    exit 0
  fi
}

# exits with error if $hasToken does not have SecureToken
# (unless running macOS 10.15 or later, in which case exit with explanation)
check_securetoken_admin () {
  if /usr/sbin/sysadminctl -secureTokenStatus "$hasToken" 2>&1 | /usr/bin/grep -q "DISABLED" ; then
    if [ "$macOSVersionMajor" -gt 10 ] || [ "$macOSVersionMajor" -eq 10 ] && [ "$macOSVersionMinor" -gt 14 ]; then
      echo "⚠️ Neither ${hasToken} nor ${getToken} has a SecureToken, but in macOS 10.15 or later, a SecureToken is automatically granted to the first user to enable FileVault (if no other users have SecureToken), so this may not be necessary. Try enabling FileVault for ${getToken}. If that fails, see what other user on the system has SecureToken, and use its credentials to grant SecureToken to ${getToken}."
      exit 0
    else
      echo "❌ ERROR: ${hasToken} does not have a valid SecureToken, unable to proceed. Please update to another admin user with SecureToken."
      exit 1
    fi
  else
    echo "✅ Verified ${hasToken} has SecureToken."
  fi
}

# adds SecureToken to target user
securetoken_add () {
  /usr/sbin/sysadminctl \
    -adminUser "$hasToken" \
    -adminPassword "$hasTokenPassword" \
    -secureTokenOn "$getToken" \
    -password "$getTokenPassword"

  # verify successful SecureToken add
  secureTokenCheck=$(/usr/sbin/sysadminctl -secureTokenStatus "${getToken}" 2>&1)
  if echo "$secureTokenCheck" | /usr/bin/grep -q "DISABLED"; then
    echo "❌ ERROR: Failed to add SecureToken to ${getToken}. Please rerun policy; if issue persists, a manual SecureToken add will be required to continue."
    osascript -e 'Tell current application to display dialog "❌ ERROR: Failed to add SecureToken to ${getToken}."'
    exit 126
  elif echo "$secureTokenCheck" | /usr/bin/grep -q "ENABLED"; then
    echo "Successfully added SecureToken to user account '${getToken}.'"
    osascript -e 'Tell current application to display dialog "Successfully added SecureToken to ${getToken}."'
  else
    echo "❌ ERROR: Unexpected result, unable to proceed. Please rerun policy; if issue persists, a manual SecureToken add will be required to continue."
    osascript -e 'Tell current application to display dialog "❌ ERROR: Failed for unknown reason.'    
    exit 1
  fi
}

# prerequisites
check_macos_version
check_securetoken_user
check_securetoken_admin

# add SecureToken using input credentials
securetoken_add "$hasToken" "$hasTokenPassword" "$getToken" "$getTokenPassword"

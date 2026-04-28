#!/bin/bash
set -euo pipefail

# 1.2 260428 PWC
# better error handling
# support for nvm-installed Node.js

# current user
loggedInUser=$(/usr/bin/stat -f%Su "/dev/console") || {
  echo "Error: Could not determine logged-in user" >&2
  exit 1
}

id "$loggedInUser" &>/dev/null || {
  echo "Error: User '$loggedInUser' does not exist" >&2
  exit 1
}

# homedir
currentUserHome=$(dscl . read "/Users/$loggedInUser" NFSHomeDirectory 2>/dev/null | awk -F': ' '{print $2}') || {
  echo "Error: Could not determine home directory for user '$loggedInUser'" >&2
  exit 1
}

# brew prefix
architectureCheck=$(/usr/bin/uname -m)
if [ "$architectureCheck" = "arm64" ]; then
  brewPrefix="/opt/homebrew/bin"
else
  brewPrefix="/usr/local/bin"
fi

brewPath="$brewPrefix/brew"

# is Homebrew installed?
if [ ! -e "$brewPath" ]; then
  echo "Error: Homebrew not found at $brewPath" >&2
  exit 1
fi

# is nvm installed?
nvmDir="$currentUserHome/.nvm"
nodeUpgraded=false

# upgrade Node via nvm if installed
if [ -s "$nvmDir/nvm.sh" ]; then
  echo "Found nvm installation at $nvmDir"
  
  # source nvm in a subshell to get nvm commands
  nodeVersionBefore=$(su - "$loggedInUser" -c ". $nvmDir/nvm.sh && node --version" 2>/dev/null) || {
    echo "Warning: Could not determine nvm Node.js version" >&2
    nodeVersionBefore="unknown"
  }
  
  # upgrade Node via nvm
  echo "Upgrading Node.js via nvm from $nodeVersionBefore..."
  su - "$loggedInUser" -c ". $nvmDir/nvm.sh && nvm install node" || {
    echo "Error: nvm node upgrade failed" >&2
    exit 1
  }
  
  # set as default if upgrade successful
  su - "$loggedInUser" -c ". $nvmDir/nvm.sh && nvm alias default node" || {
    echo "Warning: Could not set upgraded node as default" >&2
  }
  
  nodeVersionAfter=$(su - "$loggedInUser" -c ". $nvmDir/nvm.sh && node --version" 2>/dev/null) || {
    echo "Warning: Could not determine new nvm Node.js version" >&2
    nodeVersionAfter="unknown"
  }
  
  echo "nvm Node.js upgrade complete: $nodeVersionBefore → $nodeVersionAfter"
  nodeUpgraded=true
fi

# upgrade Node via Homebrew if installed
if sudo -u "$loggedInUser" "$brewPath" list --formula | grep -q '^node$'; then
  currentVersion=$(sudo -u "$loggedInUser" "$brewPath" info node | grep -oP 'node \K[0-9]+\.[0-9]+\.[0-9]+' | head -1) || {
    echo "Warning: Could not determine current Node.js version" >&2
    currentVersion="unknown"
  }
  
  echo "Upgrading Homebrew Node.js from $currentVersion..."
  sudo -u "$loggedInUser" "$brewPath" upgrade node || {
    echo "Error: Homebrew upgrade failed" >&2
    exit 1
  }
  
  newVersion=$(sudo -u "$loggedInUser" "$brewPath" info node | grep -oP 'node \K[0-9]+\.[0-9]+\.[0-9]+' | head -1) || {
    echo "Warning: Could not determine new Node.js version" >&2
    newVersion="unknown"
  }
  
  echo "Homebrew Node.js upgrade complete: $currentVersion → $newVersion"
  nodeUpgraded=true
fi

# if no Node
if [ "$nodeUpgraded" = false ]; then
  echo "Warning: No Node.js installation found (via Homebrew or nvm)" >&2
  exit 0
fi

exit 0

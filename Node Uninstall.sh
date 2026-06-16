#!/bin/bash

# 1.1 250616 - Updated for Jamf Pro execution without logged-in user
# Removes Node.js installations from system-level locations

set -e  # Exit on error

# Jamf Pro Script Log
echo "Starting Node.js uninstallation script..."

# Function to safely remove a file or directory
remove_path() {
    local path="$1"
    if [ -e "$path" ]; then
        echo "Removing $path..."
        rm -rf "$path"
    else
        echo "Path not found: $path"
    fi
}

# Function to check if command exists in PATH
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Uninstalling Node.js..."

# Uninstall Node.js installed via Homebrew (Intel)
if command_exists brew && brew list node >/dev/null 2>&1; then
    echo "Node.js found via Homebrew (Intel). Uninstalling..."
    brew uninstall -f node 2>/dev/null || echo "Homebrew uninstall failed, continuing..."
fi

# Uninstall Node.js installed via Homebrew (Apple Silicon)
if [ -d "/opt/homebrew" ]; then
    if /opt/homebrew/bin/brew list node >/dev/null 2>&1; then
        echo "Node.js found via Homebrew (Apple Silicon). Uninstalling..."
        /opt/homebrew/bin/brew uninstall -f node 2>/dev/null || echo "Homebrew uninstall failed, continuing..."
    fi
fi

# Define paths to remove
declare -a paths_to_remove=(
    "/usr/local/lib/node_modules"
    "/usr/local/include/node"
    "/usr/local/bin/node"
    "/usr/local/bin/npm"
    "/usr/local/bin/npx"
    "/usr/local/share/man/man1/node.1"
    "/usr/local/share/man/man1/npm.1"
    "/usr/local/share/systemtap/tapset/node.stp"
    "/opt/homebrew/bin/node"
    "/opt/homebrew/bin/npm"
    "/opt/homebrew/bin/npx"
    "/opt/homebrew/lib/node_modules"
    "/opt/homebrew/share/man/man1/node.1"
    "/opt/homebrew/share/man/man1/npm.1"
    "/opt/local/bin/node"
    "/opt/local/bin/npm"
    "/opt/local/bin/npx"
    "/opt/local/lib/node_modules"
    "/usr/local/nvm"
    "/usr/local/npm-cache"
)

echo "Removing Node.js files from system locations..."
for path in "${paths_to_remove[@]}"; do
    remove_path "$path"
done

echo "Node.js uninstallation completed successfully."
exit 0

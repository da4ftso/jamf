#!/bin/bash

# 1.0 250430 vibe

echo "Uninstalling Node.js..."

# function to delete a file or directory if it exists
remove_path() {
    if [ -e "$1" ]; then
        echo "Removing $1"
        sudo rm -rf "$1"
    fi
}

# uninstall Node.js installed via Homebrew
if command -v brew &> /dev/null && brew list node &> /dev/null; then
    echo "Node.js found via Homebrew. Uninstalling..."
    brew uninstall node
fi

# uninstall NVM-managed Node.js versions
if [ -d "$HOME/.nvm" ]; then
    echo "Found NVM. Removing NVM and Node versions managed by it..."
    remove_path "$HOME/.nvm"
    remove_path "$HOME/.npm"
    remove_path "$HOME/.node-gyp"
    sed -i.bak '/NVM_DIR/d' ~/.bash_profile ~/.zshrc ~/.profile 2>/dev/null
fi

# remove Node.js files from /usr/local (common for pkg installs and manual installs)
echo "Removing Node.js system files..."
remove_path "/usr/local/lib/node_modules"
remove_path "/usr/local/include/node"
remove_path "/usr/local/bin/node"
remove_path "/usr/local/bin/npm"
remove_path "/usr/local/bin/npx"
remove_path "/usr/local/share/man/man1/node.1"
remove_path "/usr/local/share/systemtap/tapset/node.stp"

# remove Node.js from /opt/homebrew (Apple Silicon Homebrew)
remove_path "/opt/homebrew/bin/node"
remove_path "/opt/homebrew/bin/npm"
remove_path "/opt/homebrew/lib/node_modules"

# remove cached files
remove_path "$HOME/.npm"
remove_path "$HOME/.node-gyp"

echo "Node.js has been uninstalled."

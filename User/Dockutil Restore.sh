#!/bin/zsh

# might be useful to keep N-1 backups, so user blah blah blah

# use with "Dockutil Backup"
set -euo pipefail

CURRENT_USER=$(stat -f %Su /dev/console)
USER_HOME=$(dscl . -read "/Users/$CURRENT_USER" NFSHomeDirectory | awk '{print $2}')

BACKUP_DIR="$USER_HOME/.dock_backups"
TARGET_PLIST="$USER_HOME/Library/Preferences/com.apple.dock.plist"

# most recent backup file
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/com.apple.dock_*.plist 2>/dev/null | head -n 1)

if [[ -z "$LATEST_BACKUP" || ! -f "$LATEST_BACKUP" ]]; then
    echo "ERROR: No valid backup plist found in: $BACKUP_DIR"
    exit 1
fi

cp "$LATEST_BACKUP" "$TARGET_PLIST"
chown "$CURRENT_USER" "$TARGET_PLIST"

sudo -u "$CURRENT_USER" killall Dock || true

# echo "Dock restored from: $LATEST_BACKUP"

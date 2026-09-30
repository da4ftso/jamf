#!/bin/sh

# $4: temporary admin duration in minutes (default: 15 min)

readonly LOG_FILE="/var/log/jamf-temporary-admin.log"
readonly DEFAULT_DURATION_MINUTES=15

log_message()
{
    message="$1"

    /bin/echo "$(/bin/date '+%Y-%m-%d %H:%M:%S') $message" >> "$LOG_FILE"
    /usr/bin/logger -t "jamf-temporary-admin" "$message"
}

# root down
if [ "$(/usr/bin/id -u)" -ne 0 ]; then
    log_message "ERROR: Script must run as root."
    exit 1
fi

# Determine the current console user.
console_user=$(/usr/bin/stat -f '%Su' /dev/console)

case "$console_user" in
    ""|root|loginwindow|_mbsetupuser)
        log_message "ERROR: No valid standard console user is logged in."
        exit 1
        ;;
esac

# Parameter 4 specifies the admin duration in minutes.
duration_minutes="${4:-$DEFAULT_DURATION_MINUTES}"

# Require a positive whole number.
case "$duration_minutes" in
    ''|*[!0-9]*|0)
        log_message "WARNING: Invalid duration '$duration_minutes'; using ${DEFAULT_DURATION_MINUTES} minutes."
        duration_minutes="$DEFAULT_DURATION_MINUTES"
        ;;
esac

duration_seconds=$((duration_minutes * 60))
user_uid=$(/usr/bin/id -u "$console_user" 2>/dev/null)

if [ -z "$user_uid" ]; then
    log_message "ERROR: Could not determine UID for '$console_user'."
    exit 1
fi

# Do not modify users who already have admin rights.
if /usr/sbin/dseditgroup \
    -o checkmember \
    -m "$console_user" \
    admin >/dev/null 2>&1
then
    log_message "User '$console_user' is already an administrator; no changes made."
    exit 0
fi

label="com.company.jamf.temporary-admin.${user_uid}"
demotion_script="/var/root/${label}.sh"
launch_daemon="/Library/LaunchDaemons/${label}.plist"

# Remove an old scheduling job for this user, if present.
if [ -f "$launch_daemon" ]; then
    /bin/launchctl bootout system "$launch_daemon" >/dev/null 2>&1
    /bin/rm -f "$launch_daemon"
fi

/bin/rm -f "$demotion_script"

# Create the delayed demotion helper.
cat > "$demotion_script" <<'DEMOTION_SCRIPT'
#!/bin/sh

console_user="$1"
duration_seconds="$2"
duration_minutes="$3"
log_file="$4"
launch_daemon="$5"
demotion_script="$6"

log_message()
{
    message="$1"

    /bin/echo "$(/bin/date '+%Y-%m-%d %H:%M:%S') $message" >> "$log_file"
    /usr/bin/logger -t "jamf-temporary-admin" "$message"
}

/bin/sleep "$duration_seconds"

if /usr/sbin/dseditgroup \
    -o checkmember \
    -m "$console_user" \
    admin >/dev/null 2>&1
then
    if /usr/sbin/dseditgroup \
        -o edit \
        -d "$console_user" \
        -t user \
        admin >/dev/null 2>&1
    then
        if /usr/sbin/dseditgroup \
            -o checkmember \
            -m "$console_user" \
            admin >/dev/null 2>&1
        then
            log_message "ERROR: User '$console_user' still has admin rights after the demotion command."
        else
            log_message "Removed temporary admin rights from '$console_user' after ${duration_minutes} minutes."
        fi
    else
        log_message "ERROR: Failed to remove admin rights from '$console_user'."
    fi
else
    log_message "User '$console_user' was no longer an administrator when the demotion job ran."
fi

/bin/rm -f "$launch_daemon"
/bin/rm -f "$demotion_script"

exit 0
DEMOTION_SCRIPT

/bin/chmod 700 "$demotion_script"
/usr/sbin/chown root:wheel "$demotion_script"

# Create a one-time LaunchDaemon that survives completion of the Jamf policy.
cat > "$launch_daemon" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${label}</string>

    <key>ProgramArguments</key>
    <array>
        <string>${demotion_script}</string>
        <string>${console_user}</string>
        <string>${duration_seconds}</string>
        <string>${duration_minutes}</string>
        <string>${LOG_FILE}</string>
        <string>${launch_daemon}</string>
        <string>${demotion_script}</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>ProcessType</key>
    <string>Background</string>
</dict>
</plist>
EOF

/bin/chmod 600 "$launch_daemon"
/usr/sbin/chown root:wheel "$launch_daemon"

if ! /usr/bin/plutil -lint "$launch_daemon" >/dev/null 2>&1; then
    log_message "ERROR: Generated LaunchDaemon plist failed validation."
    /bin/rm -f "$launch_daemon" "$demotion_script"
    exit 1
fi

# Grant admin rights.
if ! /usr/sbin/dseditgroup \
    -o edit \
    -a "$console_user" \
    -t user \
    admin >/dev/null 2>&1
then
    log_message "ERROR: Failed to grant admin rights to '$console_user'."
    /bin/rm -f "$launch_daemon" "$demotion_script"
    exit 1
fi

# Verify that elevation succeeded.
if ! /usr/sbin/dseditgroup \
    -o checkmember \
    -m "$console_user" \
    admin >/dev/null 2>&1
then
    log_message "ERROR: Admin membership verification failed for '$console_user'."
    /bin/rm -f "$launch_daemon" "$demotion_script"
    exit 1
fi

log_message "Granted temporary admin rights to '$console_user' for ${duration_minutes} minutes."

# Start the delayed demotion job.
if ! /bin/launchctl bootstrap system "$launch_daemon" >/dev/null 2>&1; then
    log_message "ERROR: Could not start demotion job; immediately removing admin rights."

    /usr/sbin/dseditgroup \
        -o edit \
        -d "$console_user" \
        -t user \
        admin >/dev/null 2>&1

    /bin/rm -f "$launch_daemon" "$demotion_script"
    exit 1
fi

exit 0

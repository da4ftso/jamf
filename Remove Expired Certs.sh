#!/bin/bash

# script to check System keychain for expired certs matching current username and delete them

KEYCHAIN="/Library/Keychains/System.keychain"
TMPDIR="$(mktemp -d)"
DELETED_COUNT=0

cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

# Determine the console user
CURRENT_USER=$(stat -f%Su /dev/console)

if [[ "$CURRENT_USER" == "root" || -z "$CURRENT_USER" ]]; then
    echo "No logged-in user found."
    exit 0
fi

echo "Logged-in user: $CURRENT_USER"
echo

# Export all certificates
security find-certificate -a -p "$KEYCHAIN" > "$TMPDIR/certs.pem"

# Split into individual cert files
awk '
/-----BEGIN CERTIFICATE-----/ {n++; file=sprintf("'"$TMPDIR"'/cert_%03d.pem",n)}
{print > file}
' "$TMPDIR/certs.pem"

for cert in "$TMPDIR"/cert_*.pem; do
    [[ -f "$cert" ]] || continue

    SUBJECT=$(openssl x509 -in "$cert" -noout -subject 2>/dev/null)
    ENDDATE=$(openssl x509 -in "$cert" -noout -enddate 2>/dev/null | cut -d= -f2-)

    [[ -n "$ENDDATE" ]] || continue

    EXPIRY_EPOCH=$(date -j -f "%b %e %T %Y %Z" "$ENDDATE" "+%s" 2>/dev/null)
    NOW_EPOCH=$(date "+%s")

    # Skip non-expired certs
    [[ "$EXPIRY_EPOCH" -lt "$NOW_EPOCH" ]] || continue

    # Only match certs whose subject contains the current username
    if echo "$SUBJECT" | grep -qi "$CURRENT_USER"; then

        SHA1=$(openssl x509 -in "$cert" -noout -fingerprint -sha1 \
            | awk -F= '{print $2}' \
            | tr -d ':')

        echo "Deleting expired certificate:"
        echo "  User    : $CURRENT_USER"
        echo "  Subject : $SUBJECT"
        echo "  Expired : $ENDDATE"
        # echo "  SHA1    : $SHA1"

        security delete-certificate -Z "$SHA1" "$KEYCHAIN"

        if [[ $? -eq 0 ]]; then
            echo "  Result  : Deleted"
            ((DELETED_COUNT++))
        else
            echo "  Result  : FAILED"
        fi

        echo
    fi
done

echo "Expired certificates deleted: $DELETED_COUNT"

cleanup
exit 0

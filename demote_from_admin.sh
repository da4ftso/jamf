#!/bin/sh

# dseditgroup to demote the currently logged in user to standard account

/usr/sbin/dseditgroup -o edit -d $3 -t user admin

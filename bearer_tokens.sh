#!/bin/sh

# Monterey and later:

# curl -X POST -u username:password -s https://server.name.here/api/v1/auth/token | plutil -extract token raw –


# Big Sur and earlier:

# curl -X POST -u username:password -s https://server.name.here/api/v1/auth/token | python -c 'import sys, json; print json.load(sys.stdin)["token"]'

# This allows the following functions to be collapsed into one command:
# 
# Encoding the username and password in base64 format
# Obtaining a Bearer Token using Basic Authentication
# Storing the Bearer Token (if command is used in a variable.)

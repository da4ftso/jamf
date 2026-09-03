#!/bin/bash

# 1.5 260903
# check health, then bail out or update

# errors
#  0 = success
#  1 = mdatp missing or can't be executed
#  2 = health check failed
#  3 = update failed

wdav="/usr/local/bin/mdatp"

if [[ ! -x "$wdav" ]]; then
    echo "mdatp not found, exiting.."
    exit 1
fi

health=$("$wdav" health --field healthy 2>/dev/null | tr -d '"')

if [[ "$health" != "true" ]]; then
    echo "Unable to update definitions, exiting.."
    exit 2
fi

if ! "$wdav" definitions update >/dev/null 2>&1; then
    echo "Definition update failed, exiting.."
    exit 3
fi

defs_version=$("$wdav" health --field definitions_version 2>/dev/null | tr -d '"')

echo "Current definitions: $defs_version"
exit 0

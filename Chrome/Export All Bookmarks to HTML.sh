#!/bin/bash

set -euo pipefail

# 1.4.1 261120 better Safari handling, falls back to Desktop if OD not found

# current logged-in user and home folder
loggedInUser=$(/usr/bin/stat -f "%Su" /dev/console)

if [[ -z "$loggedInUser" || "$loggedInUser" == "root" || "$loggedInUser" == "loginwindow" ]]; then
    echo "ERROR: No user is currently logged in."
    exit 0
fi

userHome=$(/usr/bin/dscl . -read "/Users/$loggedInUser" NFSHomeDirectory 2>/dev/null | /usr/bin/awk '{print $2}')

if [[ -z "$userHome" || ! -d "$userHome" ]]; then
    echo "ERROR: Unable to determine home folder for $loggedInUser."
    exit 1
fi

# OneDrive path for current user
ONEDRIVE_PATH="$userHome/Library/CloudStorage/OneDrive-HealthCareServiceCorporation"

if [[ ! -d "$ONEDRIVE_PATH" ]]; then
    # alternative location
    ONEDRIVE_PATH="$userHome/OneDrive"

    if [[ ! -d "$ONEDRIVE_PATH" ]]; then
        echo "WARNING: OneDrive folder not found."
        echo "Falling back to: $userHome/Desktop"
        ONEDRIVE_PATH="$userHome/Desktop"
    fi
fi

# sources
CHROME_BOOKMARKS="$userHome/Library/Application Support/Google/Chrome/Default/Bookmarks"
EDGE_BOOKMARKS="$userHome/Library/Application Support/Microsoft Edge/Default/Bookmarks"
SAFARI_BOOKMARKS="$userHome/Library/Safari/Bookmarks.plist"

# outputs
CHROME_OUTPUT="$ONEDRIVE_PATH/chrome_bookmarks_$(date +%Y%m%d_%H%M%S).html"
EDGE_OUTPUT="$ONEDRIVE_PATH/edge_bookmarks_$(date +%Y%m%d_%H%M%S).html"
SAFARI_OUTPUT="$ONEDRIVE_PATH/safari_bookmarks_$(date +%Y%m%d_%H%M%S).html"

# export to JSON
export_json_bookmarks() {
    local BOOKMARKS_FILE="$1"
    local OUTPUT_FILE="$2"
    local BROWSER_NAME="$3"

    if [[ ! -f "$BOOKMARKS_FILE" ]]; then
        echo "WARNING: $BROWSER_NAME bookmarks file not found at $BOOKMARKS_FILE"
        return 1
    fi

    echo "Exporting $BROWSER_NAME bookmarks..."
    echo "Source: $BOOKMARKS_FILE"
    echo "Output: $OUTPUT_FILE"

    python3 <<EOF
import json
import html
from datetime import datetime

BOOKMARKS_FILE = "${BOOKMARKS_FILE}"
OUTPUT_FILE = "${OUTPUT_FILE}"

try:
    with open(BOOKMARKS_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception as e:
    print(f"Error reading bookmarks file: {e}")
    exit(1)

out = open(OUTPUT_FILE, "w", encoding="utf-8")

# Netscape bookmark file header
out.write("""<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
""")

def write_folder(node, indent=1):
    pad = "    " * indent
    name = html.escape(node.get("name", ""))

    out.write(f'{pad}<DT><H3>{name}</H3>\\n')
    out.write(f'{pad}<DL><p>\\n')

    for child in node.get("children", []):
        if child["type"] == "folder":
            write_folder(child, indent + 1)
        elif child["type"] == "url":
            url = html.escape(child["url"])
            title = html.escape(child.get("name", url))
            out.write(f'{pad}    <DT><A HREF="{url}">{title}</A>\\n')

    out.write(f'{pad}</DL><p>\\n')

# Chrome and Edge roots: bookmark_bar, other, synced
roots = data["roots"]

for root_name in ("bookmark_bar", "other", "synced"):
    root = roots.get(root_name)

    if root and root.get("children"):
        write_folder(root)

out.write("</DL><p>\\n")
out.close()

print(f"Successfully exported to {OUTPUT_FILE}")
EOF
}

# export Safari
export_safari_bookmarks() {
    local BOOKMARKS_FILE="$1"
    local OUTPUT_FILE="$2"

    if [[ ! -f "$BOOKMARKS_FILE" ]]; then
        echo "WARNING: Safari bookmarks file not found at $BOOKMARKS_FILE"
        return 1
    fi

    echo "Exporting Safari bookmarks..."
    echo "Source: $BOOKMARKS_FILE"
    echo "Output: $OUTPUT_FILE"

    python3 <<EOF
import plistlib
import html

BOOKMARKS_FILE = "${BOOKMARKS_FILE}"
OUTPUT_FILE = "${OUTPUT_FILE}"

try:
    with open(BOOKMARKS_FILE, "rb") as f:
        data = plistlib.load(f)
except Exception as e:
    print(f"Error reading Safari bookmarks: {e}")
    exit(1)

out = open(OUTPUT_FILE, "w", encoding="utf-8")

# Netscape bookmark file header
out.write("""<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
""")

def write_safari_node(node, indent=1):
    pad = "    " * indent

    if not isinstance(node, dict):
        return

    bookmark_type = node.get("WebBookmarkType")

    if bookmark_type == "WebBookmarkTypeLeaf":
        url = node.get("URLString", "")
        title = node.get("URIDictionary", {}).get("title") or node.get("Title") or url

        if url:
            out.write(
                f'{pad}<DT><A HREF="{html.escape(url)}">'
                f'{html.escape(title)}</A>\\n'
            )
        return

    if bookmark_type == "WebBookmarkTypeList":
        children = node.get("Children", [])
        title = node.get("Title")

        # Skip Safari's unnamed internal containers while retaining their contents
        if not title:
            for child in children:
                write_safari_node(child, indent)
            return

        out.write(f'{pad}<DT><H3>{html.escape(title)}</H3>\\n')
        out.write(f'{pad}<DL><p>\\n')

        for child in children:
            write_safari_node(child, indent + 1)

        out.write(f'{pad}</DL><p>\\n')

# Process Safari bookmarks
if "Children" in data:
    for child in data["Children"]:
        write_safari_node(child)

out.write("</DL><p>\\n")
out.close()

print(f"Successfully exported to {OUTPUT_FILE}")
EOF
}

# export
export_json_bookmarks "$CHROME_BOOKMARKS" "$CHROME_OUTPUT" "Chrome" || echo "Chrome export skipped"
echo ""
export_json_bookmarks "$EDGE_BOOKMARKS" "$EDGE_OUTPUT" "Edge" || echo "Edge export skipped"
echo ""
export_safari_bookmarks "$SAFARI_BOOKMARKS" "$SAFARI_OUTPUT" || echo "Safari export skipped"
echo ""
# echo "Files saved to: $ONEDRIVE_PATH"

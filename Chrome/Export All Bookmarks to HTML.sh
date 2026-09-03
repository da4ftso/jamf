#!/bin/bash
set -euo pipefail

# Exports bookmarks from Chrome, Edge, and Safari to the user's OneDrive folder
# Based on the original Chrome bookmarks exporter

# OneDrive path for current user
ONEDRIVE_PATH="$HOME/Library/CloudStorage/OneDrive-Personal"
if [[ ! -d "$ONEDRIVE_PATH" ]]; then
    # Try alternative OneDrive location
    ONEDRIVE_PATH="$HOME/OneDrive"
    if [[ ! -d "$ONEDRIVE_PATH" ]]; then
        echo "ERROR: OneDrive folder not found."
        echo "Checked: $HOME/Library/CloudStorage/OneDrive-Personal and $HOME/OneDrive"
        exit 1
    fi
fi

# Define bookmark sources for each browser
CHROME_BOOKMARKS="$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
EDGE_BOOKMARKS="$HOME/Library/Application Support/Microsoft Edge/Default/Bookmarks"
SAFARI_BOOKMARKS="$HOME/Library/Safari/Bookmarks.plist"

# Define output paths
CHROME_OUTPUT="$ONEDRIVE_PATH/chrome_bookmarks_$(date +%Y%m%d_%H%M%S).html"
EDGE_OUTPUT="$ONEDRIVE_PATH/edge_bookmarks_$(date +%Y%m%d_%H%M%S).html"
SAFARI_OUTPUT="$ONEDRIVE_PATH/safari_bookmarks_$(date +%Y%m%d_%H%M%S).html"

# Function to export Chrome-like bookmarks (JSON format)
export_json_bookmarks() {
    local BOOKMARKS_FILE="$1"
    local OUTPUT_FILE="$2"
    local BROWSER_NAME="$3"
    
    if [[ ! -f "$BOOKMARKS_FILE" ]]; then
        echo "WARNING: $BROWSER_NAME bookmarks file not found at $BOOKMARKS_FILE"
        return 1
    fi
    
    echo "Exporting $BROWSER_NAME bookmarks…"
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
    out.write(f'{pad}<DT><H3>{name}</H3>\n')
    out.write(f'{pad}<DL><p>\n')

    for child in node.get("children", []):
        if child["type"] == "folder":
            write_folder(child, indent + 1)
        elif child["type"] == "url":
            url = html.escape(child["url"])
            title = html.escape(child.get("name", url))
            out.write(f'{pad}    <DT><A HREF="{url}">{title}</A>\n')

    out.write(f'{pad}</DL><p>\n')

# Chrome and Edge roots: bookmark_bar, other, synced
roots = data["roots"]

for root_name in ("bookmark_bar", "other", "synced"):
    root = roots.get(root_name)
    if root and root.get("children"):
        write_folder(root)

out.write("</DL><p>\n")
out.close()
print(f"Successfully exported to {OUTPUT_FILE}")
EOF
}

# Function to export Safari bookmarks
export_safari_bookmarks() {
    local BOOKMARKS_FILE="$1"
    local OUTPUT_FILE="$2"
    
    if [[ ! -f "$BOOKMARKS_FILE" ]]; then
        echo "WARNING: Safari bookmarks file not found at $BOOKMARKS_FILE"
        return 1
    fi
    
    echo "Exporting Safari bookmarks…"
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

def write_safari_folder(node, indent=1):
    pad = "    " * indent
    
    if isinstance(node, dict):
        # This is a folder
        title = node.get("Title", "Untitled")
        out.write(f'{pad}<DT><H3>{html.escape(title)}</H3>\n')
        out.write(f'{pad}<DL><p>\n')
        
        if "Children" in node:
            for child in node["Children"]:
                write_safari_folder(child, indent + 1)
        
        out.write(f'{pad}</DL><p>\n')

# Process Safari bookmarks
if "Children" in data:
    for child in data["Children"]:
        if "WebBookmarkType" in child:
            if child["WebBookmarkType"] == "WebBookmarkTypeList":
                write_safari_folder(child)
            elif child["WebBookmarkType"] == "WebBookmarkTypeLeaf":
                url = child.get("URLString", "")
                title = child.get("Title", url)
                if url:
                    out.write(f'    <DT><A HREF="{html.escape(url)}">{html.escape(title)}</A>\n')

out.write("</DL><p>\n")
out.close()
print(f"Successfully exported to {OUTPUT_FILE}")
EOF
}

# Main execution
echo "======================================"
echo "Browser Bookmarks Exporter"
echo "OneDrive Path: $ONEDRIVE_PATH"
echo "======================================"
echo ""

# Export Chrome bookmarks
export_json_bookmarks "$CHROME_BOOKMARKS" "$CHROME_OUTPUT" "Chrome" || echo "Chrome export skipped"
echo ""

# Export Edge bookmarks
export_json_bookmarks "$EDGE_BOOKMARKS" "$EDGE_OUTPUT" "Edge" || echo "Edge export skipped"
echo ""

# Export Safari bookmarks
export_safari_bookmarks "$SAFARI_BOOKMARKS" "$SAFARI_OUTPUT" || echo "Safari export skipped"
echo ""

echo "======================================"
echo "All exports complete!"
echo "Files saved to: $ONEDRIVE_PATH"
echo "======================================"

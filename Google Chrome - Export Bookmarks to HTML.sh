#!/bin/bash
set -euo pipefail

# replaces the previous .py version:
# https://github.com/bdesham/chrome-export/blob/main/export-chrome-bookmarks

# $HOME should work, if not use currentUserHome (eval)

CHROME_BOOKMARKS="$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
OUTPUT_HTML="$HOME/Desktop/chrome_bookmarks_$(date +%Y%m%d).html"

if [[ ! -f "$CHROME_BOOKMARKS" ]]; then
    echo "ERROR: Chrome bookmarks file not found."
    echo "Is Chrome installed and has it been run at least once?"
    exit 1
fi

echo "Exporting Chrome bookmarks…"
echo "Source: $CHROME_BOOKMARKS"
echo "Output: $OUTPUT_HTML"

python3 <<EOF
import json
import html
from datetime import datetime

BOOKMARKS_FILE = "${CHROME_BOOKMARKS}"
OUTPUT_FILE = "${OUTPUT_HTML}"

with open(BOOKMARKS_FILE, "r", encoding="utf-8") as f:
    data = json.load(f)

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

# Chrome roots: bookmark_bar, other, synced
roots = data["roots"]

for root_name in ("bookmark_bar", "other", "synced"):
    root = roots.get(root_name)
    if root and root.get("children"):
        write_folder(root)

out.write("</DL><p>\n")
out.close()
EOF

echo "Done."
echo "HTML bookmarks file created:"
echo "$OUTPUT_HTML"

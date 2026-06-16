#!/bin/bash
# set env pipefail here?

# Remove files and directories
files_to_remove=(
	"APP"
	"LIBRARYAPPDIR"
)

for f in "${files_to_remove[@]}"; do
	if [[ -e "$f" ]]; then
		echo "Deleting: $f"
		rm -Rf "$f"
	fi
done

echo "Uninstall complete."
exit 0

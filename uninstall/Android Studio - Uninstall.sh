#!/bin/bash
# set env pipefail here?

# also do we want to forget receipts or only do that as part of a 'clean' uninstall script?

# Remove files and directories
files_to_remove=(
	"/Applications/Android Studio.app"
)

for f in "${files_to_remove[@]}"; do
	if [[ -e "$f" ]]; then
		echo "Deleting: $f"
		rm -Rf "$f"
	fi
done

echo "Uninstall complete."
exit 0

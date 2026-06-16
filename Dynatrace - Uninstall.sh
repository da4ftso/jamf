#!/bin/bash
# set env pipefail here?

# where does this app leave its working dirs etc?

# Remove files and directories
files_to_remove=(
	"/Applications/Dynatrace Desktop App.app"
)

for f in "${files_to_remove[@]}"; do
	if [[ -e "$f" ]]; then
		echo "Deleting: $f"
		rm -Rf "$f"
	fi
done

echo "Uninstall complete."
exit 0

#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Loop through all directories in the current directory
for dir in "$CUR_DIR"/*/; do
    script="${dir}uninstall.sh"
    if [ -f "$script" ]; then
        echo "Executing: $script"
        #(cd "$dir" && bash "uninstall.sh")
        echo $script
    fi
done

echo "All uninstall operations completed."
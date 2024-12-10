#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Loop through all directories in the current directory
for dir in "$CUR_DIR"/*/; do
    script="${dir}install.sh"
    if [ -f "$script" ]; then
        echo "Executing: $script"
        (cd "$dir" && bash "install.sh")
    fi
done

echo "All installations completed."

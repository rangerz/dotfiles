#!/usr/bin/env bash

set -e

CUR_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Define a list of directories with priority scripts
PRIORITY_DIRS=(
    "homebrew"
)

# Function to execute an install script in a directory
run_install_script() {
    local dir="$1"
    local script="${dir}install.sh"
    if [ -f "$script" ]; then
        echo "Executing: $script"
        (cd "$dir" && bash "install.sh")
    fi
}

# 1. Execute scripts from the priority list first
for dir in "${PRIORITY_DIRS[@]}"; do
    run_install_script "$CUR_DIR/$dir/"
done

# 2. Execute all other install.sh scripts in the directories
for dir in "$CUR_DIR"/*/; do
    # Skip directories that are already in the priority list
    if [[ " ${PRIORITY_DIRS[@]} " =~ " $(basename "$dir") " ]]; then
        continue
    fi

    run_install_script "$dir"
done

echo "All installations completed."

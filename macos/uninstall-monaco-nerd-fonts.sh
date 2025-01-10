#!/usr/bin/env bash

set -e

# Define font directory and font file names
FONT_DIR="${HOME}/Library/Fonts"
FONT_FILES=(
    "MonacoNerdFont-Regular.ttf"
    "MonacoNerdFontMono-Regular.ttf"
)

# Delete each font file if it exists
for FONT_FILE in "${FONT_FILES[@]}"; do
    FONT_PATH="${FONT_DIR}/${FONT_FILE}"
    if [ -f "${FONT_PATH}" ]; then
        echo "Deleting ${FONT_FILE}..."
        rm "${FONT_PATH}"
    else
        echo "${FONT_FILE} not found, skipping."
    fi
done

echo "[Monaco Nerd Fonts] Uninstallation completed."
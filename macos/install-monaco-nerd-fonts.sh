#!/usr/bin/env bash

set -e

# Define font URLs and the directory to store fonts
FONT_DIR="${HOME}/Library/Fonts"
FONT_URLS=(
    # Monaco Nerd Font
    "https://raw.githubusercontent.com/Karmenzind/monaco-nerd-fonts/refs/heads/master/fonts/MonacoNerdFont-Regular.ttf"

    # Monaco Nerd Font Mono
    "https://raw.githubusercontent.com/Karmenzind/monaco-nerd-fonts/refs/heads/master/fonts/MonacoNerdFontMono-Regular.ttf"
)

# Create the font directory if it doesn't exist
mkdir -p "${FONT_DIR}"

# Download each font if not already present
cd "${FONT_DIR}"

for URL in "${FONT_URLS[@]}"; do
    FONT_FILE=$(basename "${URL}")
    if [ ! -f "${FONT_FILE}" ]; then
        echo "Downloading ${FONT_FILE}..."
        curl -O -L "${URL}"
    else
        echo "${FONT_FILE} already exists, skipping."
    fi
done

echo "[Monaco Nerd Fonts] Installation completed."
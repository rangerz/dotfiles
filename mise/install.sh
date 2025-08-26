#!/usr/bin/env bash
set -euo pipefail

if ! command -v mise >/dev/null 2>&1; then
    echo "[mise] mise is not installed or not in PATH."
    exit 1
fi

mise use -g node@lts python@3 rust

echo "[mise] Installation completed."

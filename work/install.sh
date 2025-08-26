#!/usr/bin/env bash
set -euo pipefail


if command -v brew >/dev/null 2>&1; then
    brew install flyctl
fi

if command -v npm >/dev/null 2>&1; then
    npm install -g @shopify/cli@latest
fi

if command -v rustup >/dev/null 2>&1; then
    rustup target add wasm32-wasip1
fi

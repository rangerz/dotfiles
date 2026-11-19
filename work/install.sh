#!/usr/bin/env bash
set -euo pipefail

if command -v brew >/dev/null 2>&1; then
    brew install flyctl
fi

if command -v mise >/dev/null 2>&1; then
    mise use -g npm:@shopify/cli
fi

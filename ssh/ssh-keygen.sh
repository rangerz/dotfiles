#!/usr/bin/env zsh
set -euo pipefail

# Check if the ed25519 key already exists
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "Generating ed25519 SSH key..."
    ssh-keygen -t ed25519 -a 100 -f "$HOME/.ssh/id_ed25519" -N ""
else
    echo "ed25519 SSH key already exists, skipping..."
fi

# Check if the RSA key already exists
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "Generating RSA SSH key..."
    ssh-keygen -t rsa -b 4096 -o -a 100 -f "$HOME/.ssh/id_rsa" -N ""
else
    echo "RSA SSH key already exists, skipping..."
fi

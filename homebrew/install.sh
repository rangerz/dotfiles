#!/usr/bin/env bash

set -e

[[ "$(uname)" == "Darwin" ]] || { echo "Support MacOS only."; exit 0; }

if command -v brew &> /dev/null; then
    echo "Homebrew is already installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

formulae=(
    mas
    node
    pnpm
    php
    composer
    python
    wget
    colordiff
    git-delta
    git-extras
)

brew install "${formulae[@]}"

casks=(
    google-chrome
    microsoft-edge
    firefox
    appcleaner
    caffeine
    rectangle
    the-unarchiver
    microsoft-teams
    diffmerge
    visual-studio-code
    phpstorm
    sequel-pro
    azure-data-studio
    iterm2
    mark-text
    docker
    postman
    notion
    vlc
)

brew install --cask "${formulae[@]}"

brew cleanup

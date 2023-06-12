#!/usr/bin/env bash

# Close any open System Preferences panes to avoid overriding upcoming changes.
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# https://github.com/mathiasbynens/dotfiles/blob/main/.macos

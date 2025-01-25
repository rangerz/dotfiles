#!/usr/bin/env bash

set -e

# 1. Remove npm (node)
brew remove --force node

# 2. Remove folders node created
rm -rf "$(brew --prefix)/lib/node_modules"
rm -rf ~/.npm

# 3. Check path for node and npm
# which node | grep brew
# which npm | grep brew

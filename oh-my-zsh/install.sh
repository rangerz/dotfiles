#!/usr/bin/env bash

set -e

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh is installed"
    exit
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Please manually add oh-my-zsh setting into ~/.zshrc"
exit

# Edit in ~/.zshrc for setting
# plugins
plugins=(
  aws
  brew
  colored-man-pages
  colorize
  git
  gitfast
  git-prompt
  docker
  docker-compose
  extract
  pip
  python
  macos
  z
)

# oh-my-zsh's plugins
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

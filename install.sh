#!/bin/bash

# Install in ~/config
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd )"

# Shell Config
SHRC=~/.bashrc
case $SHELL in
*/zsh)
    SHRC=~/.zshrc
    ;;
*/bash)
    SHRC=~/.bashrc
    ;;
*)
    echo "Unknown SHELL env"
esac

echo "# Ranger's Config" >> $SHRC
echo "test -e $DIR/.sh_profile && source $DIR/.sh_profile" >> $SHRC
echo "Apply Shell Config: exec \$SHELL"

# Vim Config
echo "source $DIR/.vimrc" >> ~/.vimrc
mkdir -p ~/.vim/.backup
mkdir -p ~/.vim/.swp
mkdir -p ~/.vim/.undo

# Git Config
git config --add --global include.path "$DIR/.gitconfig"

# DiffMerge: https://sourcegear.com/diffmerge/webhelp/sec__git.html
# Detla: https://github.com/dandavison/delta
if [[ "$OSTYPE" == "darwin"* ]]; then
    git config --add --global include.path "$DIR/.gitconfig_diffmerge_macosx"
    git config --add --global include.path "$DIR/.gitconfig_detla"
fi

# SSH Config
mkdir -p ~/.ssh/mux
cp -f $DIR/.ssh_config ~/.ssh/config

#!/usr/bin/env zsh
set -euo pipefail

ZSHRC="$HOME/.zshrc"
PLUGINS_SH="$HOME/.dotfiles/oh-my-zsh/plugins.sh"
PATTERN='source[[:space:]].*\$ZSH/oh-my-zsh\.sh'

install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh is installed"
        exit 0
    fi

    RUNZSH=no CHSH=no KEEP_ZSHRC=no OVERWRITE_CONFIRMATION=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

set_zshrc_plugins() {
    cp "$ZSHRC" "$ZSHRC.bak"

    # Remove existing plugins
    sed -e '/^plugins=(.*)$/d' \
        -e '/^plugins=(/,/^[[:space:]]*)[[:space:]]*$/d' \
        "$ZSHRC" >"$ZSHRC.tmp"

    # Add plugins before "source $ZSH/oh-my-zsh.sh"
    if grep -Eq "$PATTERN" "$ZSHRC.tmp"; then
        # before the source line
        sed "\|$PATTERN|,\$ d" "$ZSHRC.tmp" >"$ZSHRC"

        # new plugins block
        cat "$PLUGINS_SH" >>"$ZSHRC"

        # add the source line and after
        sed -n "\|$PATTERN|,\$p" "$ZSHRC.tmp" >>"$ZSHRC"
    else
        # append at end if no source line
        cat "$ZSHRC.tmp" "$PLUGINS_SH" >"$ZSHRC"
    fi

    rm -f "$ZSHRC.tmp"
}

main() {
    install_oh_my_zsh
    set_zshrc_plugins

    echo "plugins updated in $ZSHRC (backup: $ZSHRC.bak)"
}

main "$@"

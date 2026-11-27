#!/usr/bin/env zsh
# shellcheck disable=SC1071 # zsh script, not supported by shellcheck
set -euo pipefail

ZSHRC="$HOME/.zshrc"
PLUGINS_SH="$HOME/.dotfiles/oh-my-zsh/plugins.sh"
PATTERN='source[[:space:]].*\$ZSH/oh-my-zsh\.sh'

install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        # return, not exit: main must still sync the plugins block
        echo "oh-my-zsh is installed"
        return 0
    fi

    RUNZSH=no CHSH=no KEEP_ZSHRC=no OVERWRITE_CONFIRMATION=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

set_zshrc_plugins() {
    # Keep the first backup only, so a bad rewrite on a later run cannot overwrite the original
    [ -f "$ZSHRC.bak" ] || cp "$ZSHRC" "$ZSHRC.bak"

    # Remove existing plugins, plus the shellcheck header that plugins.sh carries in
    sed -e '/copied into ~\/.zshrc by install.sh$/d' \
        -e '/^plugins=(.*)$/d' \
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

    echo "plugins updated in $ZSHRC (first-run backup: $ZSHRC.bak)"
}

main "$@"

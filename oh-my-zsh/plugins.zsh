# ZSH Custom Plugins

if command -v brew &>/dev/null; then
    BREW_PREFIX="$(brew --prefix)"
    ZSH_PLUGIN_PREFIX="$BREW_PREFIX/share"
else
    ZSH_PLUGIN_PREFIX="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
fi

# zsh-autosuggestions
source "$ZSH_PLUGIN_PREFIX/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-syntax-highlighting
source "$ZSH_PLUGIN_PREFIX/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# zsh-completions
FPATH="$ZSH_PLUGIN_PREFIX/zsh-completions:$FPATH"
autoload -Uz compinit
compinit
# shellcheck shell=bash disable=SC2034 # sourced by .zshrc; oh-my-zsh reads plugins
plugins=(
    # --- Environment / System level ---
    aws    # AWS CLI completions
    brew   # Homebrew completions
    docker # Docker completions
    direnv # Load/unload .envrc automatically
    sudo   # sudo with !!

    # --- Shell usability level ---
    history-substring-search # Search history with arrows
    fzf                      # Fuzzy finder (files, dirs, history, git, etc.)
    zoxide                   # Smarter cd command

    # --- Dev / Project level ---
    git     # Git aliases + completions
    extract # Extract any archive with x
    npm     # NPM completions
    pip     # Pip completions
    mise    # Mise completions
)

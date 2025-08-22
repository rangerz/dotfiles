for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
    if [[ -x "$prefix/bin/brew" ]]; then
        eval "$("$prefix/bin/brew" shellenv)"
        return
    fi
done

if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
fi

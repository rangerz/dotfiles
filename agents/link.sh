# shellcheck shell=bash
# Sourced by agents/*/install.sh; the caller sets AGENT (e.g. "claude") for log messages

# Back up an existing real file, or a link to somewhere else, before linking
# .bak always holds the file moved away last (uninstall restores it); an older .bak gets a timestamp
link() {
    local src="$1" target="$2"
    if [[ -e "$target" && ! -L "$target" ]] ||
        [[ -L "$target" && "$(readlink "$target")" != "$src" ]]; then
        if [[ -e "$target.bak" || -L "$target.bak" ]]; then
            mv "$target.bak" "$target.bak.$(date +%Y%m%d%H%M%S)"
        fi
        mv "$target" "$target.bak"
        echo "[$AGENT] Backed up existing $target to $target.bak"
    fi
    mkdir -p "$(dirname "$target")"
    ln -sfn "$src" "$target"
}

# Shell flags
_is_zsh=$([[ -n "${ZSH_VERSION:-}" ]] && echo 1 || echo 0)
_is_bash=$([[ -n "${BASH_VERSION:-}" ]] && echo 1 || echo 0)
_is_interactive=$([[ $- == *i* ]] && echo 1 || echo 0)

# Basics
export CLICOLOR=1
export EDITOR=/usr/bin/vim
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Set block size for ls/df/du (BSD vs GNU)
export BLOCKSIZE=1k  # macOS BSD ls
export BLOCK_SIZE=1K # GNU coreutils

# Homebrew analytics off and env hints off
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

# Homebrew shellenv (macOS and LinuxBrew)
if command -v brew >/dev/null 2>&1; then
    eval "$(/usr/bin/env brew shellenv)"
fi

if [[ $- == *i* ]]; then
    # navigation
    alias ..="cd .."
    alias cd..="cd ../"
    alias ...="cd ../.."
    alias ....="cd ../../.."
    alias .....="cd ../../../.."
    alias ~="cd ~" # `cd` is probably faster to type though
    alias -- -="cd -"

    # common dirs
    alias dl="cd ~/Downloads"
    alias ws="cd ~/Workspaces"
    alias dt="cd ~/Desktop"
    alias dfs="cd ~/.dotfiles"

    # common bins
    alias c="clear"
    alias q="exit"
    alias vi="vim"
    alias h="history"
    alias vf="vimdiff"
    alias which="type"
    alias help="tldr"
    alias f="fzf"

    # ls family
    if command -v lsd >/dev/null 2>&1; then
        alias ls="lsd -Fh --group-dirs=first --icon=always --date '+%Y-%m-%d %H:%M:%S'"
        alias ll="ls -l"
        alias la="ls -lA"
    else
        alias ls="ls -GFh"
        alias ll="ls -FGlhp"
        alias la="ls -lAh"
    fi

    # grep/rg
    alias rg="rg --color=always --smart-case"
    alias grep="grep --color=auto --binary-files=without-match"
    alias egrep="egrep --color=auto --binary-files=without-match"
    alias fgrep="fgrep --color=auto --binary-files=without-match"

    if command -v bat >/dev/null 2>&1; then
        alias cat="bat --style=plain --paging=never --color=always"
    fi

    alias df="df -H"
    alias du="du -ch"
    alias rm="rm -iv"
    alias cp="cp -iv"
    alias mv="mv -iv"
    alias mkdir="mkdir -pv"
    alias less="less -FSRXc"
    alias wget="wget -c"
    alias ping="ping -c 5"
    alias ps="ps aux"
fi

# sudo alias: keep alias expansion after sudo
alias sudo="sudo "
alias sudoe="sudo -E"

# small utils
alias path='echo "$PATH" | tr ":" "\n"'
alias resh="exec ${SHELL} -l"

alias editHosts="sudo vim /etc/hosts"
alias flush="dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

alias openPorts="sudo lsof -i | grep LISTEN"
alias lsock="sudo lsof -i -P"
alias lsockU="sudo lsof -nP | grep UDP"
alias lsockT="sudo lsof -nP | grep TCP"

alias sha256="shasum -a 256 "
alias sha1="shasum "
alias hg="history | grep "

alias ip="curl ip.gs"
alias ip2="dig +short myip.opendns.com @resolver1.opendns.com"
alias ip3="curl ifconfig.me"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Homebrew and APT updates
alias brewery="brew update && brew upgrade && brew upgrade --cask && brew autoremove && brew cleanup && brew doctor"
alias brewdeps="brew deps --tree --installed"
alias aptup="sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean"
alias update="brew upgrade topgrade && topgrade && brew cleanup && brew doctor"

# Functions
if [[ $- == *i* ]]; then
    # override cd only in interactive shell
    cd() {
        builtin cd "$@"
        ls -al
    }
fi
mcd() { mkdir -p "$1" && cd "$1"; }
zipf() { zip -r "$1".zip "$1"; }
edit() {
    if command -v subl >/dev/null 2>&1; then
        subl "$@"
    elif command -v code >/dev/null 2>&1; then
        code -w "$@"
    else
        "$EDITOR" "$@"
    fi
}

# Git
export GPG_TTY=$(tty) # Ensure GPG pinentry works
alias g="git"
alias glf="git log --oneline | fzf \
  --preview \"echo {} | awk '{print \\\$1}' | xargs -I % git show --color=always % \" \
  --preview-window=right:70%:wrap"
alias gsf="git status -s | fzf \
  --preview \"echo {} | awk '{print \\\$2}' | xargs -I % git diff --color=always % \" \
  --preview-window=right:70%:wrap"

# ZOXIDE
if command -v zoxide &>/dev/null; then
    # Already handled by .zshrc zoxide plugin
    #((_is_zsh)) && eval "$(zoxide init zsh)"

    ((_is_bash)) && eval "$(zoxide init bash)"
fi

# MISE
if command -v mise &>/dev/null; then
    # Already handled by .zshrc direnv plugin
    #((_is_zsh)) && eval "$(mise activate zsh)"

    ((_is_bash)) && eval "$(mise activate bash)"
fi

# DIRENV
if command -v direnv &>/dev/null; then
    export VIRTUAL_ENV_DISABLE_PROMPT=1

    if ! typeset -f venv_prompt >/dev/null; then
        venv_prompt() {
            if [[ -n "$VIRTUAL_ENV" ]]; then
                printf '(%s) ' "${VIRTUAL_ENV:t}" # basename folder name only
            fi
        }
    fi

    case $PROMPT in
    *'$(venv_prompt)'*) ;;
    *) PROMPT='$(venv_prompt)'"$PROMPT" ;;
    esac

    # Already handled by oh-my-zsh direnv plugin
    #((_is_zsh)) && eval "$(direnv hook zsh)"

    ((_is_bash)) && eval "$(direnv hook bash)"
fi

# PIP
export PIP_REQUIRE_VIRTUALENV=true
pip-if-venv() { command pip "$@"; }
alias pip="pip-if-venv"

# NPM
if command -v npm >/dev/null 2>&1; then
    alias nr="npm run"
    alias ni="npm install"
    alias nrd="npm run dev"

    npm config set fund false
    npm config set audit false
    npm config set legacy-peer-deps true
fi

# oh-my-zsh
if (($_is_zsh)) && command -v brew &>/dev/null; then
    ZSH_CUSTOM_PLUGINS="$(brew --prefix)/share"

    # zsh-completions
    if [ -d "$ZSH_CUSTOM_PLUGINS/zsh-completions" ]; then
        FPATH="$ZSH_CUSTOM_PLUGINS/zsh-completions:$FPATH"
        autoload -Uz compinit
        compinit -u -C
    fi

    # zsh-autosuggestions
    if [ -f "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
        source "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi

    # zsh-syntax-highlighting
    if [ -f "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
        source "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
fi

if (($_is_zsh)); then
    # history-substring-search
    export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
    export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=green,bold'
    export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'
    zstyle ':history-substring-search:*' case-sensitive no
fi

# fzf
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --info=inline --multi"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview 'bat --style=numbers --color=always {} | head -100'"

# pbcopy for chatGPT
if command -v pbcopy >/dev/null 2>&1; then
    alias clip='pbcopy'
elif command -v clip.exe >/dev/null 2>&1; then
    alias clip='clip.exe'
else
    echo "clipboard command not found"
fi

alias clip-review='(printf "根據 diff staged 去 code review，指出潛在 bug、可讀性問題與改進建議：\n\n"; git diff --cached | sed -n "1,400p") | clip'
alias clip-commit='(printf "根據 diff staged 產生一則清楚、精簡、符合 Conventional Commits 的 commit message：\n\n"; git diff --cached) | clip'
alias clip-pr='(printf "根據 show commit，產生可直接貼到 GitHub 的 Pull Request 英文說明（Markdown 格式）：\n\n"; git show HEAD) | clip'

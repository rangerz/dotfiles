#!/usr/bin/env bash
# Self-check for the top-level install.sh/uninstall.sh and the cloud SessionStart hook,
# run against a throwaway HOME with stub modules (no network, no real files touched)
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
REPO="$CUR_DIR/.."
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

MODULES=(wsl zsh oh-my-zsh brew shell git ssh vim mise topgrade claude)
LOG="$TMP_HOME/log"
DOTFILES="$TMP_HOME/.dotfiles"

fail() {
    echo "[scripts test] FAIL: $1" >&2
    exit 1
}

# Commit with a throwaway identity and no signing, so the host's git config does not matter
git_commit() { git -C "$1" -c user.name=test -c user.email=test@example.com -c commit.gpgSign=false commit -qm "$2" "${@:3}"; }

# A real repo pushed to a local bare remote: install.sh's pull is a no-op, uninstall.sh sees no local work
make_dotfiles() {
    rm -rf "$DOTFILES" "$TMP_HOME/remote.git"
    git init -q --bare "$TMP_HOME/remote.git"
    mkdir -p "$DOTFILES"
    git -C "$DOTFILES" init -q -b main
    git -C "$DOTFILES" remote add origin "$TMP_HOME/remote.git"
    local mod
    for mod in "${MODULES[@]}"; do
        mkdir -p "$DOTFILES/$mod"
        printf '#!/bin/sh\necho "install %s" >>"%s"\n' "$mod" "$LOG" >"$DOTFILES/$mod/install.sh"
        printf '#!/bin/sh\necho "uninstall %s" >>"%s"\n' "$mod" "$LOG" >"$DOTFILES/$mod/uninstall.sh"
    done
    # Failures here must not stop the rest
    printf '#!/bin/sh\necho "install wsl" >>"%s"\nexit 1\n' "$LOG" >"$DOTFILES/wsl/install.sh"
    printf '#!/bin/sh\necho "uninstall oh-my-zsh" >>"%s"\nexit 1\n' "$LOG" >"$DOTFILES/oh-my-zsh/uninstall.sh"
    chmod +x "$DOTFILES"/*/*.sh
    git -C "$DOTFILES" add -A
    git_commit "$DOTFILES" stubs
    # push.negotiate (if the host sets it) only warns against a local bare repo
    git -C "$DOTFILES" -c push.negotiate=false push -q -u origin main
}

# A stub zsh records the final `exec zsh -l`
mkdir -p "$TMP_HOME/bin"
printf '#!/bin/sh\necho "exec zsh" >>"%s"\n' "$LOG" >"$TMP_HOME/bin/zsh"
chmod +x "$TMP_HOME/bin/zsh"

# Run with POSIX sh, as the README's curl | sh does; print the log on one line
run() {
    : >"$LOG"
    HOME="$TMP_HOME" PATH="$TMP_HOME/bin:$PATH" sh "$@" >/dev/null 2>&1
}
logged() { tr '\n' ' ' <"$LOG" | sed 's/ $//'; }
expect_log() {
    [[ "$(logged)" == "$2" ]] || fail "$1: expected [$2], got [$(logged)]"
}

make_dotfiles

# Full install: every module in order (wsl failing does not stop it), then switch to zsh
run "$REPO/install.sh" || fail "full install failed"
expect_log "full install" "$(printf "install %s " "${MODULES[@]}")exec zsh"

# --only keeps install order, accepts spaces after commas, and does not switch to zsh
run "$REPO/install.sh" --only "claude, git" || fail "--only failed"
expect_log "--only 'claude, git'" "install git install claude"

# Bad --only input exits non-zero before running any module
for args in "--only" "--only ," "--only foo" "--only git claude" "--bogus"; do
    # shellcheck disable=SC2086 # split args on purpose
    if run "$REPO/install.sh" $args; then
        fail "install.sh $args should fail"
    fi
    expect_log "install.sh $args" ""
done

# Uninstall: answer y, every module in order (oh-my-zsh failing does not stop it), then remove the repo
expected="$(printf 'uninstall %s ' shell git ssh vim mise topgrade claude oh-my-zsh zsh wsl brew | sed 's/ $//')"
run "$REPO/uninstall.sh" <<<y || fail "uninstall failed"
expect_log "uninstall" "$expected"
[[ ! -e "$DOTFILES" ]] || fail "uninstall did not remove $DOTFILES"

# Uninstall refuses while the repo has uncommitted work
make_dotfiles
touch "$DOTFILES/local-change"
if run "$REPO/uninstall.sh" <<<y; then
    fail "uninstall should refuse with uncommitted changes"
fi
expect_log "uninstall with local work" ""
[[ -f "$DOTFILES/local-change" ]] || fail "uninstall removed local work"

# Uninstall refuses with a commit on a branch that has no upstream, or with a stash
make_dotfiles
git -C "$DOTFILES" checkout -q -b local-only
git_commit "$DOTFILES" local --allow-empty
if run "$REPO/uninstall.sh" <<<y; then
    fail "uninstall should refuse with a commit on a branch without upstream"
fi
[[ -d "$DOTFILES" ]] || fail "uninstall removed a branch without upstream"
make_dotfiles
echo change >>"$DOTFILES/git/install.sh"
git -C "$DOTFILES" -c user.name=test -c user.email=test@example.com stash -q
if run "$REPO/uninstall.sh" <<<y; then
    fail "uninstall should refuse with a stash"
fi
[[ -d "$DOTFILES" ]] || fail "uninstall removed a stash"

# The SessionStart hook does nothing outside Claude Code cloud sessions
project="$TMP_HOME/project"
git init -q "$project"
out="$(env -u CLAUDE_CODE_REMOTE CLAUDE_PROJECT_DIR="$project" "$REPO/.claude/hooks/session-start.sh" 2>&1)" ||
    fail "session-start hook failed outside the cloud"
[[ -z "$out" ]] || fail "session-start hook printed output outside the cloud: $out"
if git -C "$project" config core.hooksPath >/dev/null; then
    fail "session-start hook set core.hooksPath outside the cloud"
fi

echo "[scripts test] OK"

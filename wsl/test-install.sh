#!/usr/bin/env bash
# Self-check for install.sh's WSL detection and apt package list, run with stubbed dpkg/apt-get/sudo
# (nothing installed); the WSL check reads a fake /proc/version via a patched copy of the script
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

BIN="$TMP_HOME/bin"
LOG="$TMP_HOME/calls"
VERSION="$TMP_HOME/version"
INSTALL="$TMP_HOME/install.sh"
mkdir "$BIN"
fail() {
    echo "[wsl test] FAIL: $1" >&2
    exit 1
}
sed "s|/proc/version|$VERSION|" "$CUR_DIR/install.sh" >"$INSTALL"
chmod +x "$INSTALL"
grep -qF "$VERSION" "$INSTALL" || fail "could not patch the /proc/version path"

# dpkg -s fails for the packages listed in $TMP_HOME/missing; apt-get and sudo only record their call
# shellcheck disable=SC2016 # $2 is for the stub, not this script
printf '#!/bin/sh\ngrep -qxF "$2" "%s" && exit 1\nexit 0\n' "$TMP_HOME/missing" >"$BIN/dpkg"
printf '#!/bin/sh\necho "sudo $*" >>"%s"\n' "$LOG" >"$BIN/sudo"
printf '#!/bin/sh\nexit 0\n' >"$BIN/apt-get"
chmod +x "$BIN"/*

run_install() {
    : >"$LOG"
    env PATH="$BIN:$PATH" "$INSTALL" </dev/null >/dev/null
}

# Not WSL: skipped, nothing installed
echo "Linux version 6.8.0-generic (buildd@ubuntu)" >"$VERSION"
printf 'wslu\n' >"$TMP_HOME/missing"
run_install
[[ ! -s "$LOG" ]] || fail "installed outside WSL: $(cat "$LOG")"

# WSL with everything installed: apt is not touched
echo "Linux version 5.15.167.4-microsoft-standard-WSL2" >"$VERSION"
: >"$TMP_HOME/missing"
run_install
[[ ! -s "$LOG" ]] || fail "ran apt with nothing missing: $(cat "$LOG")"

# WSL with some missing: only those are installed, after an update
printf 'wslu\nfonts-noto-cjk\n' >"$TMP_HOME/missing"
run_install
[[ "$(cat "$LOG")" == "sudo apt-get update
sudo apt-get install -y wslu fonts-noto-cjk" ]] || fail "unexpected apt calls: $(cat "$LOG")"

# Non-apt distro: a hint and exit 0, with only grep on PATH for the WSL check
mkdir "$TMP_HOME/noapt"
ln -s "$(command -v grep)" "$TMP_HOME/noapt/grep"
env PATH="$TMP_HOME/noapt" "$BASH" "$INSTALL" </dev/null >/dev/null 2>"$TMP_HOME/stderr" || fail "non-apt distro did not exit 0"
grep -q 'Non-apt distro' "$TMP_HOME/stderr" || fail "no hint for a non-apt distro"

echo "[wsl test] OK"

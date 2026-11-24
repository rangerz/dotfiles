#!/usr/bin/env bash
# SessionStart hook: install the tools that AGENTS.md checks need, in Claude Code cloud sessions only
set -euo pipefail

# Local machines get these tools from brew/Brewfile, so do nothing outside the cloud
if [[ "${CLAUDE_CODE_REMOTE:-}" != true ]]; then
    exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}"

# shfmt: pinned to the CI version; go fetches the toolchain it needs
if ! command -v shfmt >/dev/null 2>&1; then
    GOBIN=/usr/local/bin go install mvdan.cc/sh/v3/cmd/shfmt@v3.14.1
fi

# Install the missing ones of shellcheck, jq and zsh (oh-my-zsh/test-install.sh) from apt
missing=()
for cmd in shellcheck jq zsh; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
if ((${#missing[@]} > 0)); then
    apt-get update -q
    apt-get install -y -q "${missing[@]}"
fi

# Enable this repo's pre-commit hook only; git/install.sh would also override the cloud's commit signing
git config core.hooksPath .githooks

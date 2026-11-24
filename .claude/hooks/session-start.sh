#!/usr/bin/env bash
# SessionStart hook: install the tools that AGENTS.md checks need, in Claude Code cloud sessions only
set -euo pipefail

# Local machines get these tools from brew/Brewfile, so do nothing outside the cloud
if [[ "${CLAUDE_CODE_REMOTE:-}" != true ]]; then
    exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}"

# shfmt: same pinned release binary as CI; a failure must not skip the steps below
SHFMT_VERSION=v3.14.1
if ! command -v shfmt >/dev/null 2>&1; then
    if curl -fsSL -o /usr/local/bin/shfmt \
        "https://github.com/mvdan/sh/releases/download/$SHFMT_VERSION/shfmt_${SHFMT_VERSION}_linux_amd64"; then
        chmod +x /usr/local/bin/shfmt
    else
        rm -f /usr/local/bin/shfmt
        echo "[session-start] shfmt install failed, continuing" >&2
    fi
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

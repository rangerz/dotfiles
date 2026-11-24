# Repository Guidelines

Dotfiles for macOS, Linux, and WSL. Each module directory (`brew/`, `git/`, `mise/`, …) has its own `install.sh`/`uninstall.sh`; run the one you touched to test. Brew packages live in `brew/Brewfile`.

## Style
- `#!/usr/bin/env bash` + `set -euo pipefail`, 4-space indent.
- Installers must be idempotent (guard with `command -v` / `grep -qF`).
- Script dir: `CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"`.

## Checks
`scripts/check.sh` must pass: shellcheck, `shfmt -d .` (fix with `shfmt -w .`) and every `*/test-install.sh`. CI runs it on push and PR. `.githooks/pre-commit` runs both on staged scripts (enabled by `git/install.sh`).
In Claude Code cloud sessions, `.claude/hooks/session-start.sh` installs these tools and enables the hook; do not run `git/install.sh` there (it overrides commit signing).

## Commits
Conventional Commits with folder scope, e.g. `feat(git): add delta config`.

## Security
Never commit secrets or keys; `ssh/` is templates only.

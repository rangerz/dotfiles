# Repository Guidelines

Dotfiles for macOS, Linux, and WSL. The repo always lives at `~/.dotfiles` (install.sh clones it there), so scripts may use that path directly. Each module directory (`brew/`, `git/`, `mise/`, …) has its own `install.sh`/`uninstall.sh`; run the one you touched to test. Brew packages live in `brew/Brewfile`.

## Style
- `#!/usr/bin/env bash` + `set -euo pipefail`, 4-space indent.
- Installers must be idempotent (guard with `command -v` / `grep -qF`).
- Script dir: `CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"`.
- Keep `README.zh-TW.md` in sync with `README.md`.

## Checks
`scripts/check.sh` must pass: shellcheck, `shfmt -d .` (fix with `shfmt -w .`) and every `*/test-install.sh`. CI runs it on push and PR. `.githooks/pre-commit` runs the lint on staged scripts and every test on the staged copy (enabled by `git/install.sh`). Add a `<module>/test-install.sh` for installer logic you change; both pick it up.
In Claude Code cloud sessions, `.claude/hooks/session-start.sh` installs these tools and enables the hook; `git/install.sh` there only enables the hook and skips `include.path` (it would override commit signing).

## Commits
Conventional Commits with folder scope, e.g. `feat(git): add delta config`.

## Security
Never commit secrets or keys; `ssh/` is templates only.

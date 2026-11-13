# Repository Guidelines

## Project Structure & Module Organization
This repo is a set of reproducible dotfiles and setup scripts for macOS, Linux, and Windows/WSL. Top-level entry points are `install.sh` and `uninstall.sh`. Tool-specific modules live in directories such as `brew/`, `git/`, `zsh/`, `shell/`, `ssh/`, `vim/`, `oh-my-zsh/`, and `mise/`, each containing its own `install.sh`/`uninstall.sh`. Windows and WSL scripts are under `windows/`, and usage notes live in `docs/`.

## Build, Test, and Development Commands
- `./install.sh`: apply configs for the current OS.
- `./uninstall.sh`: remove configs for the current OS.
- `git/install.sh` (or `brew/install.sh`, etc.): run a single module installer.
- `pwsh -File windows/install-winget-apps.ps1`: install Windows apps via Winget.
- `pwsh -File windows/install-wsl-ubuntu.ps1`: WSL Ubuntu setup.
- Tip: validate changes in a fresh shell, e.g., `exec zsh`.

## Coding Style & Naming Conventions
Shell scripts use `#!/usr/bin/env bash` and `set -euo pipefail`. Indentation is 4 spaces (no tabs). Prefer functions with `local` variables, and keep installs idempotent (e.g., guard with `command -v` or `grep -qF`). Resolve script directories with:
`CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"`.
OS checks should use `case "$(uname -S 2>/dev/null || uname -s)" in Linux|Darwin) ... esac`.
Module installers are always named `install.sh`/`uninstall.sh` in lowercase directories.

## Testing Guidelines
Static checks: `shellcheck **/*.sh` and `shfmt -d .` (format with `shfmt -w .`). Manual E2E: run the module installer you touched and verify side effects (Git includes, shell RC updates). Cross-OS: avoid breaking non-target OS paths when possible.

## Commit & Pull Request Guidelines
Commit messages follow Conventional Commits with folder scope, e.g., `feat(git): add delta config` or `fix(brew): persist shellenv to .zprofile`. PRs should include a concise description, affected OS(es), test notes, and before/after behavior. Link related `docs/` updates when applicable.

## Security & Configuration Tips
Never commit secrets or private keys; treat `ssh/` as templates only. Keep personal Git settings in `git/configs/personal.ini` or `git/configs/work.ini` without tokens. External installers (e.g., Homebrew) require network access; avoid destructive defaults.

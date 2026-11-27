# rangerz/dotfiles

**English** | [Traditional Chinese](README.zh-TW.md)

My personal dotfiles, including shell, git, vim, and ssh configs.  
These scripts help bootstrap a development environment across macOS, Linux, and Windows.

<p align="left">
  <img src="https://img.shields.io/badge/Config-Automation-green" />
  <img src="https://img.shields.io/badge/Shell-zsh%20%7C%20bash-blue" />
  <img src="https://img.shields.io/badge/OS-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey" />
</p>

---

## Install Config

```bash
# Install
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rangerz/dotfiles/main/install.sh)"

# Install only some modules (kept in install order; no switch to zsh at the end)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rangerz/dotfiles/main/install.sh)" -- --only git,claude,codex

# Uninstall
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rangerz/dotfiles/main/uninstall.sh)"
```

The repo always lives at `~/.dotfiles`; some scripts and `git/gitconfig` use that path directly.
Linux support covers WSL and other distros (apt, dnf, yum, pacman, apk for Homebrew's prerequisites).

## Structure

```text
dotfiles/
├── brew/         # Homebrew packages and scripts
├── agents/       # AI coding agent configs
│   ├── claude/   # Claude Code settings, ccstatusline, plugins
│   ├── codex/    # Codex hooks and skills
│   ├── global.md # Global instructions shared by Claude Code and Codex
│   └── mcps.txt  # MCP servers shared by Claude Code and Codex
├── docs/         # Notes: macOS, WSL, winget, vscode, etc.
├── git/          # Git config, aliases, workflow, commit templates
├── macos/        # macOS helper scripts (e.g. fix hostname)
├── mise/         # Language/runtime manager configs
├── oh-my-zsh/    # Oh My Zsh plugins and setup
├── scripts/      # Repo checks (check.sh, also run by CI)
├── shell/        # General shell config setup
├── ssh/          # SSH config and key management
├── topgrade/     # topgrade config (system-wide updates)
├── vim/          # Vim config
├── windows/      # Windows setup scripts (winget, WSL)
├── wsl/          # WSL-only packages and Chrome install
├── zsh/          # Zsh installer
├── install.sh    # Entry point installer
└── uninstall.sh  # Entry point uninstaller
```

## Post-install Setup

After installation, some personal configuration is required:

- Edit your `git/configs/personal.ini` and `git/configs/work.ini` for user-specific git settings.

- You can skip certain configs if they don’t apply:

```bash
git skip git/configs/personal.ini

# For ~/Workspaces/ only
git skip git/configs/work.ini
```

## Global Agent Instructions

`agents/global.md` holds the global instructions that Claude Code and Codex share. The installers link it to:

- `~/.claude/CLAUDE.md` (`agents/claude/install.sh`)
- `~/.codex/AGENTS.md` (`agents/codex/install.sh`)

Edit `agents/global.md` to change both. If either path already exists as a real file or a link to somewhere else, the installer renames it to `.bak` first.

## Claude Code Settings

`agents/claude/install.sh` does not symlink `agents/claude/settings.json`, because Claude Code rewrites `~/.claude/settings.json` itself. It merges the repo file into it with `jq`:

- Keys in the repo file overwrite the same keys in `~/.claude/settings.json`.
- Keys that exist only locally (for example `permissions.allow` or `hooks`) are kept.
- Removing a key from the repo file does not remove it locally.

If you change a tracked setting with `/model` or `/config`, the next install changes it back. Edit `agents/claude/settings.json` instead.

## License

[MIT](https://opensource.org/licenses/MIT)

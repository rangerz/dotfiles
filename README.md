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
│   ├── agy/      # Antigravity CLI (agy): settings, status line, instructions, next steps hook, plugins from Claude, MCPs
│   ├── codex/    # Codex hooks and skills
│   ├── global.md # Global instructions shared by Claude Code, Codex and agy
│   └── mcps.txt  # MCP servers shared by Claude Code, Codex and agy
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

`agents/global.md` holds the global instructions that Claude Code, Codex and agy share. The installers link it to:

- `~/.claude/CLAUDE.md` (`agents/claude/install.sh`)
- `~/.codex/AGENTS.md` (`agents/codex/install.sh`)
- `~/.gemini/GEMINI.md` (`agents/agy/install.sh`)

Edit `agents/global.md` to change all of them. If any of these paths already exists as a real file or a link to somewhere else, the installer renames it to `.bak` first. An older `.bak` is kept as `.bak.<timestamp>`, so `.bak` always holds the file moved away last. Uninstall removes the link and moves `.bak` back.

## Claude Code Settings

`agents/claude/install.sh` does not symlink `agents/claude/settings.json`, because Claude Code rewrites `~/.claude/settings.json` itself. It merges the repo file into it with `jq`:

- Keys in the repo file overwrite the same keys in `~/.claude/settings.json`.
- Keys that exist only locally (for example `permissions.allow` or `hooks`) are kept.
- Removing a key from the repo file does not remove it locally.

If you change a tracked setting with `/model` or `/config`, the next install changes it back. Edit `agents/claude/settings.json` instead.

## Antigravity CLI (agy) Settings

`agents/agy/install.sh` does not symlink `agents/agy/settings.json`, because agy rewrites `~/.gemini/antigravity-cli/settings.json` itself. It merges the repo file into it with `jq`:

- Keys in the repo file overwrite the same keys in `~/.gemini/antigravity-cli/settings.json`.
- Keys that exist only locally (for example `permissions.allow`, `model`, or `trustedWorkspaces`) are kept.
- `permissions.deny` is merged, not replaced: deny rules you added locally are kept, and the repo's rules are added.
- Removing a key from the repo file does not remove it locally.

If you change a tracked setting with `/config` or `/settings`, the next install changes it back. Edit `agents/agy/settings.json` instead.

## Antigravity CLI (agy) Plugins

agy cannot add marketplaces from GitHub, so it has no plugin list of its own. `agents/agy/install.sh` runs `agy plugin import claude`, which copies the plugins Claude Code installed from `agents/claude/plugins.txt`. To add a plugin to agy, add it to `agents/claude/plugins.txt`.

- topgrade keeps them in sync: after it updates the Claude Code plugins, it runs `agy plugin import claude --force` (see `topgrade/topgrade.toml`). Plugins you disabled in agy stay disabled.
- Plugins removed from Claude Code are not removed from agy.
- Plugins built only for Claude Code do nothing in agy. For example, `next-steps` only has a Claude Code hook (`hooks/register.tsx`), so agy imports it without any component. `agents/agy/install.sh` adds the same behavior as a Stop hook in `~/.gemini/config/hooks.json` instead, reusing the Codex hook (`agents/codex/hooks/next_steps.sh`).

## License

[MIT](https://opensource.org/licenses/MIT)

# rangerz/dotfiles

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

# Uninstall
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rangerz/dotfiles/main/uninstall.sh)"
```

## Structure

```text
dotfiles/
├── brew/        # Homebrew packages and scripts
├── docs/        # Notes: macOS, WSL, winget, vscode, etc.
├── git/         # Git config, aliases, workflow, commit templates
├── mise/        # Language/runtime manager configs
├── oh-my-zsh/   # Oh My Zsh plugins and setup
├── shell/       # General shell config setup
├── ssh/         # SSH config and key management
├── vim/         # Vim config
├── windows/     # Windows setup scripts (winget, WSL)
├── zsh/         # Zsh installer
├── install.sh   # Entry point installer
└── uninstall.sh # Entry point uninstaller
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

## License

[MIT](https://opensource.org/licenses/MIT)

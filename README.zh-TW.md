# rangerz/dotfiles

[English](README.md) | **繁體中文**

我的個人 dotfiles，包含 shell、git、vim 與 ssh 設定。  
這些腳本可以在 macOS、Linux 與 Windows 上快速建立開發環境。

<p align="left">
  <img src="https://img.shields.io/badge/Config-Automation-green" />
  <img src="https://img.shields.io/badge/Shell-zsh%20%7C%20bash-blue" />
  <img src="https://img.shields.io/badge/OS-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey" />
</p>

---

## 安裝設定

```bash
# 安裝
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rangerz/dotfiles/main/install.sh)"

# 只安裝部分模組（依安裝順序執行；最後不會切換到 zsh）
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rangerz/dotfiles/main/install.sh)" -- --only git,claude,codex

# 解除安裝
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rangerz/dotfiles/main/uninstall.sh)"
```

repo 固定放在 `~/.dotfiles`；部分腳本與 `git/gitconfig` 會直接使用這個路徑。
Linux 支援 WSL 與其他發行版（Homebrew 的前置套件可透過 apt、dnf、yum、pacman、apk 安裝）。

## 目錄結構

```text
dotfiles/
├── brew/         # Homebrew 套件與腳本
├── agents/       # AI coding agent 設定
│   ├── claude/   # Claude Code 設定、ccstatusline、plugins
│   ├── codex/    # Codex hooks 與 skills
│   ├── global.md # Claude Code 與 Codex 共用的全域指令
│   └── mcps.txt  # Claude Code 與 Codex 共用的 MCP servers
├── docs/         # 筆記：macOS、WSL、winget、vscode 等
├── git/          # Git 設定、alias、workflow、commit 範本
├── macos/        # macOS 輔助腳本（例如修正 hostname）
├── mise/         # 語言 / runtime 管理工具設定
├── oh-my-zsh/    # Oh My Zsh plugins 與設定
├── scripts/      # repo 檢查（check.sh，CI 也會執行）
├── shell/        # 通用 shell 設定
├── ssh/          # SSH 設定與金鑰管理
├── topgrade/     # topgrade 設定（全系統更新）
├── vim/          # Vim 設定
├── windows/      # Windows 安裝腳本（winget、WSL）
├── wsl/          # WSL 專用套件與 Chrome 安裝
├── zsh/          # Zsh 安裝程式
├── install.sh    # 安裝入口
└── uninstall.sh  # 解除安裝入口
```

## 安裝後設定

安裝完成後，需要做一些個人設定：

- 編輯 `git/configs/personal.ini` 與 `git/configs/work.ini`，填入個人的 git 設定。

- 用不到的設定檔可以略過：

```bash
git skip git/configs/personal.ini

# 只用於 ~/Workspaces/
git skip git/configs/work.ini
```

## 全域 Agent 指令

`agents/global.md` 是 Claude Code 與 Codex 共用的全域指令。安裝程式會把它連結到：

- `~/.claude/CLAUDE.md`（`agents/claude/install.sh`）
- `~/.codex/AGENTS.md`（`agents/codex/install.sh`）

要同時修改兩邊，編輯 `agents/global.md` 即可。如果這兩個路徑已經有一般檔案，或是指向其他位置的連結，安裝程式會先把它改名成 `.bak`（如果 `.bak` 已經存在，就改成 `.bak.<時間戳記>`）。解除安裝時會移除連結，並把 `.bak` 搬回原位。

## Claude Code 設定

`agents/claude/install.sh` 不會用 symlink 連結 `agents/claude/settings.json`，因為 Claude Code 會自己改寫 `~/.claude/settings.json`。安裝時改用 `jq` 把 repo 裡的檔案合併進去：

- repo 檔案中的 key 會覆蓋 `~/.claude/settings.json` 中相同的 key。
- 只存在本機的 key（例如 `permissions.allow` 或 `hooks`）會保留。
- 從 repo 檔案刪除某個 key，不會連帶刪除本機的設定。

如果用 `/model` 或 `/config` 改了 repo 有追蹤的設定，下次安裝時會被改回來。請改為編輯 `agents/claude/settings.json`。

## 授權

[MIT](https://opensource.org/licenses/MIT)

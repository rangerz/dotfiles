# Winget (Windows Package Manager)

## Usage

```bash
# Install WSL (安裝 WSL)
wsl --install

# Install specific distro (安裝特定發行版)
wsl --install -d Ubuntu
wsl --install -d Debian
wsl --install -d Ubuntu-24.04

# Show WSL status (檢查狀態)
wsl --status

# Show WSL version (檢查版本)
wsl --version

# Update WSL (更新 WSL 版本)
wsl --update

# List installed distros (列出已安裝的發行版)
wsl --list --verbose
wsl -l -v

# List available online distros (列出可安裝的發行版)
wsl --list --online
wsl -l -o

# Set default distro (設定預設發行版)
wsl --set-default Ubuntu-24.04
wsl -s Ubuntu-24.04

# Enter default distro (進入預設發行版)
wsl

# Enter specific distro (進入指定發行版)
wsl -d Ubuntu-22.04

# Shutdown all WSL instances (關閉所有 WSL)
wsl --shutdown

# Export a distro (匯出發行版)
wsl --export Ubuntu backup.tar

# Import a distro (匯入發行版)
wsl --import MyDistro D:\WSL D:\backup.tar

# Unregister (reset) a distro (重置發行版)
wsl --unregister Ubuntu
wsl --install -d Ubuntu
```

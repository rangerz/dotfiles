# mise

dev tools, env vars, task runner

## Resource

- <https://github.com/jdx/mise>
- <https://mise.jdx.dev/>

## Install

```bash
# Mac
brew install mise

# Linux
sudo apt update -y && sudo apt install -y gpg sudo wget curl
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt update
sudo apt install -y mise

# Setup for zsh
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
```

## Usage

```bash
# List all available plugins:
mise plugins list-all

# List version for node and python
mise ls-remote python
mise ls-remote node

# Install latest
mise install python@latest
mise install node@latest

# Install Specific version
mise install python@3.12.5
mise install node@20.15.0

# Set global versions (all projects)
# This updates ~/.config/mise/config.toml:
mise use -g node@lts python@3

# Set local project version (per folder)
# This creates a .mise.toml file in the current directory:
mise use python@3.11.9
mise use node@18.19.0

# List installed versions
mise ls

# Upgrade all installed versions
mise upgrade

# Uninstall specific version
mise uninstall python@3.10.14
mise uninstall node@16.20.2

# Run health check
mise doctor
```

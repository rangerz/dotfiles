# Winget (Windows Package Manager)

## Usage

```bash
# Install WSL
wsl --install

# Install specific distro
wsl --install -d Ubuntu
wsl --install -d Debian
wsl --install -d Ubuntu-24.04

# Show WSL status
wsl --status

# Show WSL version
wsl --version

# Update WSL
wsl --update

# List installed distros
wsl --list --verbose
wsl -l -v

# List available online distros
wsl --list --online
wsl -l -o

# Set default distro
wsl --set-default Ubuntu-24.04
wsl -s Ubuntu-24.04

# Enter default distro
wsl

# Enter specific distro
wsl -d Ubuntu-22.04

# Shutdown all WSL instances
wsl --shutdown

# Export a distro
wsl --export Ubuntu backup.tar

# Import a distro
wsl --import MyDistro D:\WSL D:\backup.tar

# Unregister (reset) a distro
wsl --unregister Ubuntu
wsl --install -d Ubuntu
```

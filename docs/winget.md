# Winget (Windows Package Manager)

## Resource

- <https://winget.run/>
- <https://winstall.app/>
- <https://github.com/microsoft/winget-cli>
- <https://github.com/microsoft/winget-pkgs>

## Usage

```pwsh
# Install a package
winget install -e --id Google.Chrome

# Install a package
winget remove --purge -e --id Google.Chrome

# Search for a package
winget search vscode

# Show
winget show --id Google.Chrome

# List installed packages (winget source)
winget list --source winget

# Upgrade winget self
winget upgrade --id Microsoft.AppInstaller -e

# Upgrade all packages
winget upgrade --all --accept-package-agreements --accept-source-agreements
```

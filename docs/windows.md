# Windows

## Windows Settings (Win + i)

- Windows Settings
  - System
    - Display
      - Extend desktop (Win + p)
    - Multitasking
      - Desktops
        - On the taskbar, show all the open windows -> On all desktops
        - Show all open windows when I press Alt+Tab -> On all desktops
      - Title bar windows shake -> On
    - For developers
      - Enable sudo -> On
        - Configure how sudo runs applications -> inline
  - Time & Language
    - Add a language (Chinese, Traditional, Taiwan)
    - Add a keyboard (Bopomofo)
  - Apps
    - Default apps -> Google Chrome
  - Bluetooth & devices
    - Mouse
      - Scrolling
        - Scrolling direction -> Down motion scrolls down
      - Touchpad
        - Taps
          - Tap twice and drag to multi-select -> Off
        - Scroll & zoom
          - Scrolling direction -> Down motion scrolls down
  - Personalization
    - Taskbar
      - Taskbar
        - Taskbar items
          - Search -> Hide (Win +S, three finger tap)
          - Task view -> Off
          - Widgets -> Off
        - System tray icons
          - Touch keyboard -> Never
        - Other system tray icons
          - Hidden icon menu -> On
        - Taskbar behaviors
          - Taskbar alignment -> Left
  - Privacy & security
    - Search history -> Off and Clear
    - Show search 'highlights' -> Off
    - Search my accounts
      - Microsoft account -> Off
      - Work or School account -> Off
  - Windows Update
    - Check for updates
    - Advanced options
      - Delivery Optimization
        - Allow downloads from other devices -> Off

```powershell
# Enable Windows Hello (PIN)
Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name AllowDomainPINLogon -Value 1 -Type DWord

# Timezone
Set-TimeZone -Id "Central Standard Time"

# PC Name (Reboot)
Rename-Computer -NewName "RANGER-LAPTOP" -Restart
```

## Windows Features

- Turn Windows feature on or off
  - Internet Information Services -> Off
  - Internet Information Services Hostable Web Core -> Off
  - SMB 1.0/CIFS File Sharing Support
  - Work Folders Client
  - Print and Document Services

## File Explorer Options / Folder Options

- General
  - Open File Explorer to: `This PC`
  - Privacy
    - Show recently used files -> Off
    - Show frequently used folders → Off
    - Show recommended section → Off
    - Include account-based insights, recent, favorite, and recommended files → Off
  - View
    - Display the fill path in the title bar
    - Show hidden files, folders, and drivers
    - Hide extensions for known file types -> Off

## WSL: Ubuntu

```bash
wsl --install 

wsl --install -d Ubuntu

# System update
sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y
```

## Winget (Windows Package Manager)

```powershell
# Install and check ./package/windows/winget-apps.ps1

# Install
winget install -e --id Google.Chrome

# Remove
winget remove --purge -e --id DevToys-app.DevToys

# Search
winget search vscode

# List
winget list --source winget

# Upgrade winget self
winget upgrade --id Microsoft.AppInstaller -e

# Upgrade
winget upgrade --all --accept-package-agreements --accept-source-agreements
```

## Teams

- Settings
  - Files and Links
    - Links open preference
      - Always open web links in: `Default browser`

## Notepad++

- Settings
  - Preferences
    - Indentation
      - Indent size: 4
      - Indent using: Space character(s)
    - New Document
      - Format (Lin ending)
        - Unix (LF)
  - Style Configurator
    - Theme: Dracula
      - Dracula.xml put into `%AppData%\Notepad++\themes`
      - <https://raw.githubusercontent.com/dracula/notepad-plus-plus/refs/heads/master/Dracula.xml>
    - Font name: JetBrainsMono NFM
      - JetBrainsMono NFM
- Plugins
  - Plugins Admin
    - AutoSave
    - DSpellCheck
    - HEX-Editor
    - XBracket Lite

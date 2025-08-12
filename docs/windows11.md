# Windows

### WinGet
```bash
# Install
winget install -e --id Fortinet.FortiClientVPN
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Notepad++.Notepad++
winget install -e --id Postman.Postman
winget install -e --id Microsoft.AzureDataStudio
winget install -e --id Mozilla.Firefox
winget install -e --id 7zip.7zip

# Optional Apps
winget install -e --id DevToys-app.DevToys
winget install -e --id Docker.DockerDesktop
winget install -e --id Zoom.Zoom
winget install -e --id Notion.Notion
winget install -e --id AutoIt.AutoIt

# OpenAI ChatGPT
winget install --id=9NT1R1C2HH7J --source=msstore --accept-package-agreements --accept-source-agreements –silent

# Search
winget search vscode

# List
winget list --source winget

# Upgrade winget self
winget upgrade --id Microsoft.AppInstaller -e

# Upgrade
winget upgrade --all --accept-package-agreements --accept-source-agreements
```

### WSL
```bash
```

### VPN
```au3
;================================================================================
; Auto-it script to launch FortiClient GUI and auto-fill VPN credentials
;================================================================================

; Define your username and password here
Global $sUser = "USER"
Global $sPass = "PASS"

Opt("WinTitleMatchMode", 2) ; partial match window title

; Launch FortiClient console
Run('"' & @ProgramFilesDir & '\Fortinet\FortiClient\FortiClientConsole.exe"')

; Wait up to 10 seconds for FortiClient VPN window to become active
WinWaitActive("FortiClient VPN", "", 10)
Sleep(1000) ; allow GUI to load

; Paste username into input field
ClipPut($sUser)
Send("^v")
Sleep(1000)

; Press TAB to move to password field
Send("{TAB}")
Sleep(500)

; Paste password into input field
ClipPut($sPass)
Send("^v")
Sleep(1000)

; Press ENTER to submit / connect
Send("{ENTER}")
```
#!/usr/bin/env pwsh

# Uninstall bloatware apps by Win11Debloat
# & ([scriptblock]::Create((irm "https://debloat.raphi.re/")))
# (3) App removal mode: Select & remove apps, without making other changes
# Remove default apps (https://github.com/Raphire/Win11Debloat/blob/master/Appslist.txt)

# And other apps to remove
#Microsoft.BingSearch                          # Web Search from Microsoft Bing (Integrates into Windows Search)
#Microsoft.GetHelp                             # Required for some Windows 11 Troubleshooters and support interactions
#Microsoft.WindowsCamera                       # Camera app for using built-in or connected cameras
#Microsoft.Xbox.TCUI                           # UI framework, seems to be required for MS store, photos and certain games
#Microsoft.XboxGameOverlay                     # Game overlay, required/useful for some games (Part of Xbox Game Bar)
#Microsoft.XboxGamingOverlay                   # Game overlay, required/useful for some games (Part of Xbox Game Bar)
#Microsoft.XboxIdentityProvider                # Xbox sign-in framework, required for some games and Xbox services
#Microsoft.XboxSpeechToTextOverlay             # Might be required for some games, WARNING: This app cannot be reinstalled easily! (Accessibility feature)
#Microsoft.StartExperiencesApp                 # This app powers Windows Widgets My Feed
#Microsoft.OneDrive                            # OneDrive consumer cloud storage client
#Microsoft.M365Companions                      # Microsoft 365 (Business) Calendar, Files and People mini-apps, these apps may be reinstalled if enabled by your Microsoft 365 admin
#Microsoft.WindowsCamera                       # Camera app for using built-in or connected cameras
#MicrosoftWindows.CrossDevice                  # Phone integration within File Explorer, Camera and more (Part of Phone Link features)
#Microsoft.YourPhone                           # Phone link (Connects Android/iOS phone to PC)
#Microsoft.Paint                               # Classic Paint (Traditional 2D paint application)
#Microsoft.WindowsCalculator                   # Calculator app
#Microsoft.WindowsNotepad                      # Notepad text editor app
#MicrosoftWindows.CrossDevice                  # Phone integration within File Explorer, Camera and more (Part of Phone Link features)

# Microsoft.Edge.GameAssist

#winget uninstall McAfee

# Remove Appx Packages
#Get-AppxPackage *NotepadPlusPlus* | Remove-AppxPackage
#Get-AppxPackage *Dolby* | Remove-AppxPackage
#Get-AppxPackage *Engagement* | Remove-AppxPackage


# Install Winget Packages
winget install -e --id Google.Chrome
winget install -e --id Mozilla.Firefox
winget install -e --id Fortinet.FortiClientVPN
winget install -e --id Notepad++.Notepad++
winget install -e --id Postman.Postman
winget install -e --id Microsoft.AzureDataStudio
winget install -e --id 7zip.7zip
winget install -e --id Microsoft.PowerToys
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Microsoft.Teams
winget install -e --id Microsoft.WindowsApp
winget install -e --id Microsoft.Edge
winget install -e --id Docker.DockerDesktop
winget install -e --id Notion.Notion
winget install -e --id AutoIt.AutoIt
winget install -e --id Sysinternals.Autologon
winget install -e --id Deskflow.Deskflow
winget install -e --id topgrade-rs.topgrade
winget install -e --id th-ch.YouTubeMusic
winget install -e --id eVenture.HideMe

# OpenAI ChatGPT
winget install --id=9NT1R1C2HH7J --source=msstore --accept-package-agreements --accept-source-agreements –silent

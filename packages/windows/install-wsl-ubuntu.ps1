#!/usr/bin/env pwsh

# Install WSL v2
wsl --install 

# Optional (admin)
# dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Install Ubuntu
wsl --install -d Ubuntu
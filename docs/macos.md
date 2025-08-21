# MacOS 15.2 Preferences

## System Settings

- Appearance
  - Dark Mode
- Desktop & Dock
  - Remove rarely used apps from Dock
  - Dock
    - Smaller Size and No Magnification
    - Position on screen → Left
    - Double-click a windows’s title icon → Zoom
    - Automatically hide and show the Dock → Off
    - Show indicators for open application → On
    - Show suggested and recent apps in Dock → Off
  - Desktop & Stage Manager
    - Click wallpaper to reveal desktop -> Only in Stage Manager
  - Widgets
    - Default web browser → Google Chrome.app
  - Mission Control
    - Automatically rearrange Space based on mosr recent use -> Off
  - Hot Corners (in the bottom)
    - Left Bottom: Put Display to Sleep
- Control Center
  - Wi-Fi: Show in Menu Bar
  - Battery
    - Show in Menu Bar
    - Show Percentage
- Touch ID & Password
- Notifications
  - Allow notifications when the screen is locked → Off
  - Most of Off
  - Microsoft Outlook
  - Microsoft Teams
- Apple Intelligence & Siri
  - Disable
- Trackpad
  - Pointer & Click
    - Tap to click → On
    - Tracking speed → 7
    - Look up & data detectors → Off
  - Scroll & Zoom
    - Natural scrolling → Off
  - More Gestures
    - Swipe between pages → Off
    - Launchpad → Off
  - Accessibility → Pointer Control → Trackpad Option
    - Scroll Speed: 6
    - Use trackpad for dragging → On
    - Dragging style → Three Finger Drag
- Keyboard
  - Press Fn key to → Change Input Source
  - Text Input
    - Add Zhuyin - Traditional (注音輸入法)
  - Edit "All Input Source"
    - Capitalize words automatically → Off
    - Add period with double-space → Off
    - Use smart quotes and dashes → Off
    - For double quotes → "abc"
    - For single quotes → 'abc'
  - Keyboard → Mission Control → Disable all
- Storage
  - Remove Garage Band & Sound Library
  - Remove Garage Band App
- Sharing
  - Change computer name command:
    - `sudo scutil --set ComputerName "newname"`
    - `sudo scutil --set LocalHostName "newname"`
    - `sudo scutil --set HostName "newname"`

## Build-in Apps

- Finder
  - Finder → Setting
    - General
      - New Finder windows show: ~/Downloads
      - Open folders in tabs instead of new windows → On
    - Tags
      - Hide all
    - Sidebar
      - Hide Recents
      - Add home folder
      - Hide Recent Tags
      - Hide iCloud
    - Advanced
      - Show all filename extension → On
      - Show warning before xxx → On
      - Remove items from the Trash after 30 days → On
      - When performing a search: Search the Current Folder
  - View
    - Show Sidebar
    - Show Preview
    - Show Toolbar
    - Show Path Bar
    - Show Status Bar
  - View → Show View Options (⌘J)
    - Show Item Info
    - Show Library Folder
  - ScreenShots → add to sidebar

## defaults

```zsh
# take screenshots as jpg (usually smaller size) and not png
defaults write com.apple.screencapture type jpg

# setup screetshot folder
mkdir ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots/
killall SystemUIServer

# do not open previous previewed files (e.g. PDFs) when opening a new one
defaults write com.apple.Preview ApplePersistenceIgnoreState YES

# show Library folder
chflags nohidden ~/Library

# show hidden files
defaults write com.apple.finder AppleShowAllFiles True
killall Finder
```

# Windows Terminal

Setting -> Default Profile -> Open JSON file

## settings.json

```json
{
  "launchMode": "maximized",
  "copyOnSelect": true,
  "trimBlockSelection": true,
  "trimPaste": true,
  "theme": "dark",
  "alwaysShowTabs": true,
  "showTabsInTitlebar": true,
  "useAcrylicInTabRow": false,
  "confirmCloseAllTabs": false,
  "experimental.detectURLs": true,

  "profiles": {
    "defaults": {
      "font": {
        "face": "JetBrainsMono Nerd Font Mono",
        "size": 13,
        "cellHeight": 1.2,
        "feature": { "liga": true }
      },
      "antialiasingMode": "cleartype",
      "padding": "8, 8, 8, 8",
      "bellStyle": "none",
      "cursorShape": "bar",
      "colorScheme": "One Half Dark",
      "useAcrylic": true,
      "acrylicOpacity": 0.85,
    }
  }
}
```

## Settings

- Startup
  - Launch on machine startup -> On

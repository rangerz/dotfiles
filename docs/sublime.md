# Sublime

## Install

`brew install --cask sublime-text`

## Packages

- https://packagecontrol.io/browse
- `Command + Shift + P` -> `Install Package Control`
- `Command + Shift + P` -> `Package Control: Install Package`

```text
A File Icon
Alignment
BracketHighlighter
CSS3０
Emmet
SideBarEnhancements
TrailingSpaces
```

## Settings

- Settings -> Settings

```json
{
    "update_check": true,
    "font_face": "JetBrainsMono Nerd Font Mono",
    "font_options": ["subpixel_antialias", "ligatures"],
    "font_size": 12,
    "ignored_packages": ["Vintage"],
    "tab_size": 4,
    "translate_tabs_to_spaces": true,
    "detect_indentation": false,
    "auto_indent": true
}
```

## License Key

- https://gist.github.com/skoqaq/3f3e8f28e23c881143cef9cf49d821ff

```bash
sudo perl -pi -e '@MAGIC_PATTERN@' /Applications/Sublime\ Text.app/Contents/MacOS/sublime_text
sudo codesign --sign - --force --deep /Applications/Sublime\ Text.app
```

### Learning Resources
- [開始撰寫程式碼-程式碼平台安裝(Sublime)](https://medium.com/jeasee%E9%9A%A8%E7%AD%86/%E9%96%8B%E5%A7%8B%E6%92%B0%E5%AF%AB%E7%A8%8B%E5%BC%8F%E7%A2%BC-%E7%A8%8B%E5%BC%8F%E7%A2%BC%E5%B9%B3%E5%8F%B0%E5%AE%89%E8%A3%9D-sublime-3d1184489e74)

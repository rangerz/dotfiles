# Shortcuts

## Common Shortcuts

`⌘` is for MacOS, `Ctrl` is for Windows and Linux

- Open New Tab → Ctrl/⌘ + T
- Close Tab/Pane → Ctrl/⌘ + W
- Switch Tab → Ctrl/⌘ + Tab, Ctrl/⌘ + Shift + Tab
- Switch Tab → Ctrl/⌘ + Number
- Split Pane → Ctrl/⌘ + D (Horizontal), Ctrl/⌘ + Shift + D (Vertical)
- Switch Pane → Alt + Arrow

## vscode

Ctrl/⌘ + Shift + P -> "Preferences: Open Keyboard Shortcuts (JSON)" -> keybindings.json

```json
[
  {
    "key": "cmd+d",
    "command": "workbench.action.splitEditorRight",
    "when": "editorTextFocus"
  },
  {
    "key": "cmd+shift+d",
    "command": "workbench.action.splitEditorDown",
    "when": "editorTextFocus"
  },
  {
    "key": "alt+right",
    "command": "workbench.action.focusNextGroup",
    "when": "editorTextFocus"
  },
  {
    "key": "alt+left",
    "command": "workbench.action.focusPreviousGroup",
    "when": "editorTextFocus"
  },
  {
    "key": "alt+up",
    "command": "workbench.action.focusAboveGroup",
    "when": "editorTextFocus"
  },
  {
    "key": "alt+down",
    "command": "workbench.action.focusBelowGroup",
    "when": "editorTextFocus"
  },
  {
    "key": "cmd+d",
    "command": "workbench.action.terminal.split",
    "when": "terminalFocus"
  },
  {
    "key": "cmd+w",
    "command": "workbench.action.terminal.kill",
    "when": "terminalFocus"
  },
  {
    "key": "cmd+t",
    "command": "workbench.action.terminal.focus",
    "when": "editorTextFocus"
  },
  {
    "key": "cmd+t",
    "command": "workbench.action.terminal.new",
    "when": "terminalFocus"
  },
    {
    "key": "alt+right",
    "command": "workbench.action.terminal.focusNextPane",
    "when": "terminalFocus"
  },
  {
    "key": "alt+left",
    "command": "workbench.action.terminal.focusPreviousPane",
    "when": "terminalFocus"
  },
  {
    "key": "alt+up",
    "command": "workbench.action.terminal.focusPreviousPane",
    "when": "terminalFocus"
  },
  {
    "key": "alt+down",
    "command": "workbench.action.terminal.focusNextPane",
    "when": "terminalFocus"
  },
    {
    "key": "ctrl+tab",
    "command": "workbench.action.terminal.focusNext",
    "when": "terminalFocus"
  },
  {
    "key": "ctrl+shift+tab",
    "command": "workbench.action.terminal.focusPrevious",
    "when": "terminalFocus"
  },
  {
    "key": "cmd+1",
    "command": "workbench.action.terminal.focusAtIndex1",
    "when": "terminalFocus"
  },
  {
    "key": "cmd+2",
    "command": "workbench.action.terminal.focusAtIndex2",
    "when": "terminalFocus"
  },
  {
    "key": "cmd+3",
    "command": "workbench.action.terminal.focusAtIndex3",
    "when": "terminalFocus"
  }
]
```

## iTerm2

iTerm2 → Settings → Keys → Key Bindings

Add 4 key bindings

- ⌥ + ←: Select Split Pane on Left
- ⌥ + →: Select Split Pane on Right
- ⌥ + ↑: Select Split Pane Above
- ⌥ + ↓: Select Split Pane Below

## Windows Terminal

Setting -> Default Profile -> Open JSON file

```json
{
  "actions": [
    { "command": "newTab", "keys": "ctrl+t" },
    { "command": { "action": "splitPane", "split": "horizontal" }, "keys": "ctrl+d" },
    { "command": { "action": "splitPane", "split": "vertical" }, "keys": "ctrl+shift+d" },
    { "command": "closePane", "keys": "ctrl+w" },
  ]
}
```

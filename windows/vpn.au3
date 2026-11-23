;================================================================================
; Auto-it script to launch FortiClient GUI and auto-fill VPN credentials
;================================================================================

; Credentials come from user environment variables, so no password lives in this tracked file
; Set once in PowerShell: [Environment]::SetEnvironmentVariable("VPN_USER", "...", "User") (same for VPN_PASS)
Global $sUser = EnvGet("VPN_USER")
Global $sPass = EnvGet("VPN_PASS")
If $sUser = "" Or $sPass = "" Then
    MsgBox(16, "vpn.au3", "Set the VPN_USER and VPN_PASS user environment variables first.")
    Exit 1
EndIf

Opt("WinTitleMatchMode", 2) ; partial match window title

; Launch FortiClient console
Run('"' & @ProgramFilesDir & '\Fortinet\FortiClient\FortiClientConsole.exe"')

; Wait up to 10 seconds for FortiClient VPN window to become active
WinWaitActive("FortiClient VPN", "", 10)
Sleep(1000) ; allow GUI to load

; Type username into input field
Send("{TAB}")
Send("{TAB}")
Send("{TAB}")
; Flag 1 = raw: types characters literally (no {}, +, ^, ! shortcuts) and never touches the clipboard
Send($sUser, 1)
Sleep(1000)

; Press TAB to move to password field
Send("{TAB}")
Sleep(500)

; Type password into input field (not via clipboard, so it is not left in Win+V history)
Send($sPass, 1)
Sleep(1000)

; Press ENTER to submit / connect
Send("{ENTER}")

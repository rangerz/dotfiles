;================================================================================
; Auto-it script to launch FortiClient GUI and auto-fill VPN credentials
;================================================================================

; Define your username and password here
Global $sUser = "username"
Global $sPass = "password"

Opt("WinTitleMatchMode", 2) ; partial match window title

; Launch FortiClient console
Run('"' & @ProgramFilesDir & '\Fortinet\FortiClient\FortiClientConsole.exe"')

; Wait up to 10 seconds for FortiClient VPN window to become active
WinWaitActive("FortiClient VPN", "", 10)
Sleep(1000) ; allow GUI to load

; Paste username into input field
Send("{TAB}")
Send("{TAB}")
Send("{TAB}")
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

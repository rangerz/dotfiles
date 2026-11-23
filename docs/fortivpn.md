# fortivpn with Auto-it

The script is [`windows/vpn.au3`](../windows/vpn.au3). It opens FortiClient and types the VPN credentials.

1. Set the credentials once as user environment variables (PowerShell):

    ```powershell
    [Environment]::SetEnvironmentVariable("VPN_USER", "your-user", "User")
    [Environment]::SetEnvironmentVariable("VPN_PASS", "your-password", "User")
    ```

2. Sign out and back in (or restart Explorer) so new programs see the variables.
3. Run `windows/vpn.au3` with AutoIt.

The password is typed directly and never goes through the clipboard, so it does not end up in Win+V history.

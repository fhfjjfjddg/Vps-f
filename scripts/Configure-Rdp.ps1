# Enable Remote Desktop and disable Network Level Authentication (if needed)
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
                   -Name "fDenyTSConnections" -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
                   -Name "UserAuthentication" -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
                   -Name "SecurityLayer" -Value 0 -Force

# Enable audio playback redirection
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
                   -Name "fDisableAudioRedirection" -Value 0 -Force

# Enable microphone (audio capture) redirection
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
                   -Name "fDisableAudioCapture" -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
                   -Name "AudioCaptureRedirectionMode" -Value 0 -Force

# Firewall rule for RDP
netsh advfirewall firewall delete rule name="RDP-Tailscale"
netsh advfirewall firewall add rule name="RDP-Tailscale" `
  dir=in action=allow protocol=TCP localport=3389

# Restart Remote Desktop service
Restart-Service -Name TermService -Force

Write-Host "RDP configuration applied successfully."
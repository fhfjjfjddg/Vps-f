# scripts/setup-rdp.ps1

function Setup-RDP {
    # Enable Remote Desktop and disable Network Level Authentication
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -Force
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0 -Force
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "SecurityLayer" -Value 0 -Force

    # Enable audio redirection
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "fDisableAudioRedirection" -Value 0 -Force
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "fDisableAudioCapture" -Value 0 -Force
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "AudioCaptureRedirectionMode" -Value 0 -Force

    # Set firewall rule for RDP
    netsh advfirewall firewall delete rule name="RDP-Tailscale"
    netsh advfirewall firewall add rule name="RDP-Tailscale" dir=in action=allow protocol=TCP localport=3389

    # Restart Remote Desktop service
    Restart-Service -Name TermService -Force

    # Ensure Windows Audio service is enabled and running
    Set-Service -Name "Audiosrv" -StartupType Automatic
    Start-Service -Name "Audiosrv"

    # Update all system drivers to latest available
    pnputil /scan-devices
    pnputil /update-driver * /install

    # Upgrade all winget packages to ensure the system is up-to-date
    winget upgrade --all --locale en-US --accept-package-agreements --accept-source-agreements

    # Create a new local user with a secure, random password
    Add-Type -AssemblyName System.Security
    $charSet = @{
        Upper   = [char[]](65..90)
        Lower   = [char[]](97..122)
        Number  = [char[]](48..57)
        Special = ([char[]](33..47) + [char[]](58..64) + [char[]](91..96) + [char[]](123..126))
    }
    $rawPassword = @()
    $rawPassword += $charSet.Upper | Get-Random -Count 4
    $rawPassword += $charSet.Lower | Get-Random -Count 4
    $rawPassword += $charSet.Number | Get-Random -Count 4
    $rawPassword += $charSet.Special | Get-Random -Count 4
    $password = -join ($rawPassword | Sort-Object { Get-Random })
    $securePass = ConvertTo-SecureString $password -AsPlainText -Force

    New-LocalUser -Name "RDP" -Password $securePass -AccountNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member "RDP"
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member "RDP"

    if (-not (Get-LocalUser -Name "RDP")) {
        throw "User creation failed"
    }

    # Output credentials for GitHub Actions
    echo "::set-output name=RDP_USER::RDP"
    echo "::set-output name=RDP_PASSWORD::$password"
}

Setup-RDP
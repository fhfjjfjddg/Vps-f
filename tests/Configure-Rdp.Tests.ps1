. "$PSScriptRoot/../scripts/Configure-Rdp.ps1"

Describe 'Configure-Rdp.ps1' {
    BeforeEach {
        Mock Set-ItemProperty { } -Verifiable
        Mock netsh { } -Verifiable
        Mock Restart-Service { } -Verifiable
        Mock Write-Host { } # Mock to keep output clean
    }

    It 'should set all required RDP registry keys' {
        . "$PSScriptRoot/../scripts/Configure-Rdp.ps1"

        # Verify that Set-ItemProperty was called for each required key
        Should -Invoke 'Set-ItemProperty' -Exactly 6
        Should -Invoke 'Set-ItemProperty' -Once -WithParameters @{ Path = 'HKLM:\System\CurrentControlSet\Control\Terminal Server'; Name = 'fDenyTSConnections'; Value = 0; Force = $true }
        Should -Invoke 'Set-ItemProperty' -Once -WithParameters @{ Path = 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'; Name = 'UserAuthentication'; Value = 0; Force = $true }
        Should -Invoke 'Set-ItemProperty' -Once -WithParameters @{ Path = 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'; Name = 'SecurityLayer'; Value = 0; Force = $true }
        Should -Invoke 'Set-ItemProperty' -Once -WithParameters @{ Path = 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'; Name = 'fDisableAudioRedirection'; Value = 0; Force = $true }
        Should -Invoke 'Set-ItemProperty' -Once -WithParameters @{ Path = 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'; Name = 'fDisableAudioCapture'; Value = 0; Force = $true }
        Should -Invoke 'Set-ItemProperty' -Once -WithParameters @{ Path = 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'; Name = 'AudioCaptureRedirectionMode'; Value = 0; Force = $true }
    }

    It 'should create the correct firewall rule' {
        . "$PSScriptRoot/../scripts/Configure-Rdp.ps1"

        # Verify that the firewall rule is deleted and then added
        Should -Invoke 'netsh' -Exactly 2
        Should -Invoke 'netsh' -Once -WithParameters @('advfirewall', 'firewall', 'delete', 'rule', 'name="RDP-Tailscale"')
        Should -Invoke 'netsh' -Once -WithParameters @('advfirewall', 'firewall', 'add', 'rule', 'name="RDP-Tailscale"', 'dir=in', 'action=allow', 'protocol=TCP', 'localport=3389')
    }

    It 'should restart the Remote Desktop service' {
        . "$PSScriptRoot/../scripts/Configure-Rdp.ps1"

        # Verify that the TermService is restarted
        Should -Invoke 'Restart-Service' -Once -WithParameters @{ Name = 'TermService'; Force = $true }
    }
}
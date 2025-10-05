. "$PSScriptRoot/../scripts/Enable-Audio.ps1"

Describe 'Enable-Audio.ps1' {
    BeforeEach {
        Mock Set-Service { } -Verifiable
        Mock Start-Service { } -Verifiable
        Mock pnputil { } -Verifiable
        Mock Write-Host { } # Mock to keep output clean
    }

    It 'should configure and start the Windows Audio service' {
        . "$PSScriptRoot/../scripts/Enable-Audio.ps1"

        Should -Invoke 'Set-Service' -Once -WithParameters @{ Name = 'Audiosrv'; StartupType = 'Automatic' }
        Should -Invoke 'Start-Service' -Once -WithParameters @{ Name = 'Audiosrv' }
    }

    It 'should scan for devices and update drivers' {
        . "$PSScriptRoot/../scripts/Enable-Audio.ps1"

        Should -Invoke 'pnputil' -Once -WithParameters @('/scan-devices')
        Should -Invoke 'pnputil' -Once -WithParameters @('/update-driver', '*', '/install')
    }
}
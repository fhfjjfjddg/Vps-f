. "$PSScriptRoot/../scripts/Install-Tailscale.ps1"

Describe 'Install-Tailscale.ps1' {
    BeforeEach {
        Mock winget { } -Verifiable
        Mock Write-Host { } # Mock to keep output clean
    }

    It 'should call winget to install Tailscale with the correct arguments' {
        . "$PSScriptRoot/../scripts/Install-Tailscale.ps1"

        Should -Invoke 'winget' -Once -WithParameters @('install', '-e', '--id', 'Tailscale.Tailscale', '--accept-package-agreements', '--accept-source-agreements')
    }
}
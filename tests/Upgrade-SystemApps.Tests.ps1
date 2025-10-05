. "$PSScriptRoot/../scripts/Upgrade-SystemApps.ps1"

Describe 'Upgrade-SystemApps.ps1' {
    BeforeEach {
        # Mock winget completely and clear its invocation history for each test
        Mock winget { } -Verifiable
        Mock Write-Host { } # Mock to keep output clean
    }

    Context 'When Chrome is not installed' {
        It 'should upgrade all, install Chrome, and upgrade Edge' {
            # Simulate 'winget list' returning nothing for Chrome, indicating it's not installed
            Mock winget {
                if ($args[0] -eq 'list') { return $false }
            }

            # Run the script
            . "$PSScriptRoot/../scripts/Upgrade-SystemApps.ps1"

            # Assert that the correct winget commands were called in the correct sequence
            Should -Invoke 'winget' -Once -WithParameters @('upgrade', '--all', '--accept-package-agreements', '--accept-source-agreements')
            Should -Invoke 'winget' -Once -WithParameters @('list', '--id', 'Google.Chrome')
            Should -Invoke 'winget' -Once -WithParameters @('install', '-e', '--id', 'Google.Chrome', '--accept-package-agreements', '--accept-source-agreements')
            Should -Invoke 'winget' -Once -WithParameters @('upgrade', '-e', '--id', 'Microsoft.Edge', '--accept-package-agreements', '--accept-source-agreements')
            # Ensure the upgrade command for Chrome was NOT called
            Should -Invoke 'winget' -Never -WithParameters @('upgrade', '-e', '--id', 'Google.Chrome', '--accept-package-agreements', '--accept-source-agreements')
        }
    }

    Context 'When Chrome is already installed' {
        It 'should upgrade all, upgrade Chrome, and upgrade Edge' {
            # Simulate 'winget list' finding an installation of Chrome
            Mock winget {
                if ($args[0] -eq 'list') { return $true }
            }

            # Run the script
            . "$PSScriptRoot/../scripts/Upgrade-SystemApps.ps1"

            # Assert that the correct winget commands were called in the correct sequence
            Should -Invoke 'winget' -Once -WithParameters @('upgrade', '--all', '--accept-package-agreements', '--accept-source-agreements')
            Should -Invoke 'winget' -Once -WithParameters @('list', '--id', 'Google.Chrome')
            Should -Invoke 'winget' -Once -WithParameters @('upgrade', '-e', '--id', 'Google.Chrome', '--accept-package-agreements', '--accept-source-agreements')
            Should -Invoke 'winget' -Once -WithParameters @('upgrade', '-e', '--id', 'Microsoft.Edge', '--accept-package-agreements', '--accept-source-agreements')
            # Ensure the install command for Chrome was NOT called
            Should -Invoke 'winget' -Never -WithParameters @('install', '-e', '--id', 'Google.Chrome', '--accept-package-agreements', '--accept-source-agreements')
        }
    }
}
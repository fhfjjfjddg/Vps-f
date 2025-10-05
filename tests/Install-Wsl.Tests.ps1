. "$PSScriptRoot/../scripts/Install-Wsl.ps1"

Describe 'Install-Wsl.ps1' {
    BeforeEach {
        Mock wsl { } -Verifiable
        Mock Write-Host { } # Mock to keep output clean
    }

    Context 'When WSL is not installed' {
        It 'should install WSL, update it, set the default version, and install Ubuntu' {
            # Mock 'wsl --status' to fail, indicating it's not installed
            # Mock 'wsl -l -q' to return nothing
            Mock wsl {
                if ($args[0] -eq '--status') { throw "WSL not installed" }
                if ($args -join ' ' -eq '-l -q') { return '' }
            }

            . "$PSScriptRoot/../scripts/Install-Wsl.ps1"

            Should -Invoke 'wsl' -Once -WithParameters @('--install', '--no-launch')
            Should -Invoke 'wsl' -Once -WithParameters @('--update')
            Should -Invoke 'wsl' -Once -WithParameters @('--set-default-version', '2')
            Should -Invoke 'wsl' -Once -WithParameters @('--install', '-d', 'Ubuntu')
            Should -Invoke 'wsl' -Exactly 2 -WithParameters @('--status') # Once at the start (which throws), once at the end
        }
    }

    Context 'When WSL is installed but Ubuntu is not' {
        It 'should update WSL, set the default, and install Ubuntu' {
            # Mock 'wsl --status' to succeed, but 'wsl -l -q' to return nothing
            Mock wsl {
                if ($args[0] -eq '--status') { return "WSL is installed." }
                if ($args -join ' ' -eq '-l -q') { return '' }
            }

            . "$PSScriptRoot/../scripts/Install-Wsl.ps1"

            Should -Invoke 'wsl' -Never -WithParameters @('--install', '--no-launch')
            Should -Invoke 'wsl' -Once -WithParameters @('--update')
            Should -Invoke 'wsl' -Once -WithParameters @('--set-default-version', '2')
            Should -Invoke 'wsl' -Once -WithParameters @('--install', '-d', 'Ubuntu')
        }
    }

    Context 'When WSL and Ubuntu are both installed' {
        It 'should only update WSL and set the default' {
            # Mock 'wsl --status' to succeed, and 'wsl -l -q' to return 'Ubuntu'
            Mock wsl {
                if ($args[0] -eq '--status') { return "WSL is installed." }
                if ($args -join ' ' -eq '-l -q') { return 'Ubuntu' }
            }

            . "$PSScriptRoot/../scripts/Install-Wsl.ps1"

            Should -Invoke 'wsl' -Never -WithParameters @('--install', '--no-launch')
            Should -Invoke 'wsl' -Never -WithParameters @('--install', '-d', 'Ubuntu')
            Should -Invoke 'wsl' -Once -WithParameters @('--update')
            Should -Invoke 'wsl' -Once -WithParameters @('--set-default-version', '2')
        }
    }
}
. "$PSScriptRoot/../scripts/Verify-Rdp.ps1"

Describe 'Verify-Rdp.ps1' {
    BeforeEach {
        Mock Test-NetConnection { } -Verifiable
        Mock Write-Host { } # Mock to keep output clean
        Mock Write-Error { } -Verifiable
    }

    Context 'When a valid IP is provided' {
        It 'should succeed if the TCP test succeeds' {
            Mock Test-NetConnection {
                return [pscustomobject]@{ TcpTestSucceeded = $true }
            }

            try { . "$PSScriptRoot/../scripts/Verify-Rdp.ps1" -TailscaleIp '100.1.1.1' } catch { }

            Should -Invoke 'Test-NetConnection' -Once -WithParameters @{ ComputerName = '100.1.1.1'; Port = 3389; ErrorAction = 'Stop' }
            Should -Invoke 'Write-Error' -Never
        }

        It 'should fail if the TCP test fails' {
            Mock Test-NetConnection {
                return [pscustomobject]@{ TcpTestSucceeded = $false }
            }

            try { . "$PSScriptRoot/../scripts/Verify-Rdp.ps1" -TailscaleIp '100.1.1.1' } catch { }

            Should -Invoke 'Test-NetConnection' -Once
            Should -Invoke 'Write-Error' -Once
        }

        It 'should fail if Test-NetConnection throws an error' {
            Mock Test-NetConnection {
                throw "Connection error"
            }

            try { . "$PSScriptRoot/../scripts/Verify-Rdp.ps1" -TailscaleIp '100.1.1.1' } catch { }

            Should -Invoke 'Test-NetConnection' -Once
            Should -Invoke 'Write-Error' -Once
        }
    }

    Context 'When no IP is provided' {
        It 'should fail immediately' {
            try { . "$PSScriptRoot/../scripts/Verify-Rdp.ps1" -TailscaleIp '' } catch { }

            Should -Invoke 'Test-NetConnection' -Never
            Should -Invoke 'Write-Error' -Once -WithParameter @{ Message = 'Tailscale IP was not provided. Cannot verify RDP connection.' }
        }
    }
}
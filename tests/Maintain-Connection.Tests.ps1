. "$PSScriptRoot/../scripts/Maintain-Connection.ps1"

Describe 'Maintain-Connection.ps1' {
    BeforeEach {
        Mock Start-Sleep { } -Verifiable
        Mock Write-Host { } -Verifiable
        Mock Write-Error { } -Verifiable
    }

    Context 'When all parameters are provided' {
        It 'should display the connection banner and attempt to sleep' {
            # Mock Start-Sleep to throw an exception to break the infinite loop
            Mock Start-Sleep { throw "Loop broken for test" }

            try {
                . "$PSScriptRoot/../scripts/Maintain-Connection.ps1" -TailscaleIp '100.1.1.1' -RdpUser 'testuser' -RdpPassword 'testpass'
            } catch {
                # Catch the exception we threw to break the loop
            }

            # Verify the banner was written
            Should -Invoke 'Write-Host' -AtLeast 4
            Should -Invoke 'Write-Host' -Once -WithParameters 'Address: 100.1.1.1'
            Should -Invoke 'Write-Host' -Once -WithParameters 'Username: testuser'
            Should -Invoke 'Write-Host' -Once -WithParameters 'Password: testpass'

            # Verify it entered the loop
            Should -Invoke 'Start-Sleep' -Once -WithParameters @{ Seconds = 300 }
            Should -Invoke 'Write-Error' -Never
        }
    }

    Context 'When a parameter is missing' {
        It 'should write an error and not display the banner' {
            try {
                . "$PSScriptRoot/../scripts/Maintain-Connection.ps1" -TailscaleIp '' -RdpUser 'testuser' -RdpPassword 'testpass'
            } catch {

            }

            Should -Invoke 'Write-Error' -Once
            Should -Invoke 'Start-Sleep' -Never
            # Check that the banner was not written
            Should -Invoke 'Write-Host' -Never -WithParameters 'Address: '
        }
    }
}
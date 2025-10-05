. "$PSScriptRoot/../scripts/Connect-Tailscale.ps1"

Describe 'Connect-Tailscale.ps1' {
    BeforeEach {
        # Mock the external command and sleep
        Mock tailscale.exe { } -ModuleName 'tailscale.exe' -Verifiable
        Mock Start-Sleep { } -Verifiable
        Mock Write-Host { } # Mock to keep output clean
        Mock echo {
            $script:outputtedCommands += "$($args -join ' ')"
        } -Verifiable

        $script:outputtedCommands = @()
    }

    Context 'When Tailscale connects and provides an IP on the first try' {
        It 'should call tailscale up and ip, then set the output' {
            $ip = '100.1.1.1'
            $callCount = 0
            Mock tailscale.exe {
                param($command)
                if ($command -eq 'ip') {
                    $callCount++
                    return $ip
                }
            } -ModuleName 'tailscale.exe'

            . "$PSScriptRoot/../scripts/Connect-Tailscale.ps1" -AuthKey 'testkey' -RunId '123'

            Should -Invoke 'tailscale.exe' -Once -WithParameters @('up', '--authkey=testkey', '--hostname=gh-runner-123')
            $callCount | Should -Be 1
            Should -Invoke 'Start-Sleep' -Never
            $script:outputtedCommands | Should -Contain "::set-output name=tailscale_ip::$ip"
        }
    }

    Context 'When Tailscale provides an IP after a few retries' {
        It 'should call tailscale ip multiple times and sleep in between' {
            $ip = '100.1.1.1'
            $callCount = 0
            Mock tailscale.exe {
                param($command)
                if ($command -eq 'ip') {
                    $callCount++
                    if ($callCount -ge 3) {
                        return $ip
                    }
                    return $null
                }
            } -ModuleName 'tailscale.exe'

            . "$PSScriptRoot/../scripts/Connect-Tailscale.ps1" -AuthKey 'testkey' -RunId '123'

            Should -Invoke 'tailscale.exe' -Once -WithParameters @('up', '--authkey=testkey', '--hostname=gh-runner-123')
            $callCount | Should -Be 3
            Should -Invoke 'Start-Sleep' -Exactly 2 -WithParameters @{ Seconds = 5 }
            $script:outputtedCommands | Should -Contain "::set-output name=tailscale_ip::$ip"
        }
    }

    Context 'When Tailscale fails to provide an IP' {
        It 'should try 10 times and then throw an error' {
            $callCount = 0
            Mock tailscale.exe {
                param($command)
                if ($command -eq 'ip') {
                    $callCount++
                    return $null
                }
            } -ModuleName 'tailscale.exe'
            Mock Write-Error { } -Verifiable

            try { . "$PSScriptRoot/../scripts/Connect-Tailscale.ps1" -AuthKey 'testkey' -RunId '123' } catch { }

            $callCount | Should -Be 10
            Should -Invoke 'Start-Sleep' -Exactly 9
            Should -Invoke 'Write-Error' -Once
            $script:outputtedCommands.Count | Should -Be 0
        }
    }
}
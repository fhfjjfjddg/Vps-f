. "$PSScriptRoot/../scripts/Prepare-EmulatorSupport.ps1"

Describe 'Prepare-EmulatorSupport.ps1' {
    BeforeEach {
        Mock Disable-WindowsOptionalFeature { } -Verifiable
        Mock Enable-WindowsOptionalFeature { } -Verifiable
        Mock winget { } -Verifiable
        Mock Write-Host { } # Mock to keep output clean
    }

    Context 'When Hyper-V is enabled' {
        It 'should attempt to disable Hyper-V and enable other features' {
            # Mock Get-WindowsOptionalFeature to return 'Enabled' for Hyper-V
            Mock Get-WindowsOptionalFeature {
                param($FeatureName)
                if ($FeatureName -eq 'Microsoft-Hyper-V-All') {
                    return [pscustomobject]@{ State = 'Enabled' }
                }
            } -Verifiable

            . "$PSScriptRoot/../scripts/Prepare-EmulatorSupport.ps1"

            # Verify the correct sequence of operations
            Should -Invoke 'Get-WindowsOptionalFeature' -Once -WithParameters @{ Online = $true; FeatureName = 'Microsoft-Hyper-V-All' }
            Should -Invoke 'Disable-WindowsOptionalFeature' -Once -WithParameters @{ Online = $true; FeatureName = 'Microsoft-Hyper-V-All'; NoRestart = $true }
            Should -Invoke 'Enable-WindowsOptionalFeature' -Once -WithParameters @{ Online = $true; FeatureName = 'VirtualMachinePlatform'; NoRestart = $true }
            Should -Invoke 'Enable-WindowsOptionalFeature' -Once -WithParameters @{ Online = $true; FeatureName = 'HypervisorPlatform'; NoRestart = $true }
            Should -Invoke 'winget' -Once -WithParameters @('install', '-e', '--id', 'BlueStacks.BlueStacks', '--accept-package-agreements', '--accept-source-agreements')
        }
    }

    Context 'When Hyper-V is already disabled' {
        It 'should not attempt to disable Hyper-V' {
            # Mock Get-WindowsOptionalFeature to return 'Disabled' for Hyper-V
            Mock Get-WindowsOptionalFeature {
                param($FeatureName)
                if ($FeatureName -eq 'Microsoft-Hyper-V-All') {
                    return [pscustomobject]@{ State = 'Disabled' }
                }
            } -Verifiable

            . "$PSScriptRoot/../scripts/Prepare-EmulatorSupport.ps1"

            # Verify that Disable-WindowsOptionalFeature is never called
            Should -Invoke 'Get-WindowsOptionalFeature' -Once -WithParameters @{ Online = $true; FeatureName = 'Microsoft-Hyper-V-All' }
            Should -Invoke 'Disable-WindowsOptionalFeature' -Never
            Should -Invoke 'Enable-WindowsOptionalFeature' -Exactly 2 # Still enables the other two features
            Should -Invoke 'winget' -Once
        }
    }
}
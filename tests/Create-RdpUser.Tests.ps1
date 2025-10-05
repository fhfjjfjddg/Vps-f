. "$PSScriptRoot/../scripts/Create-RdpUser.ps1"

Describe 'Create-RdpUser.ps1' {
    Context 'New-SecureRandomPassword function' {
        It 'should generate a password of the specified length' {
            $password = New-SecureRandomPassword -Length 20
            $password.Length | Should -Be 20
        }

        It 'should generate a password with at least 4 non-alphanumeric characters' {
            $password = New-SecureRandomPassword -Length 16 -NonAlphanumericChars 4
            ($password -split '[a-zA-Z0-9]' | Where-Object { $_ }).Length | Should -BeGreaterOrEqual 4
        }
    }

    Context 'User Creation Logic' {
        BeforeEach {
            # Mock all external commands to test the script's logic in isolation
            Mock New-LocalUser { } -Verifiable
            Mock Add-LocalGroupMember { } -Verifiable
            Mock ConvertTo-SecureString { "a_very_secure_string" } -Verifiable
            Mock Write-Host { } # Mock Write-Host to keep output clean
            Mock echo {
                # This mock captures the output redirection to validate it
                $output = "$($args -join ' ')"
                $script:outputtedCommands += $output
            } -Verifiable

            # Mock the password generation to have a predictable password
            Mock New-SecureRandomPassword { "Password123!@#$" } -Verifiable

            # Initialize a variable to capture the output
            $script:outputtedCommands = @()
        }

        It 'should call all cmdlets and set outputs correctly' {
            # Execute the main logic of the script
            . "$PSScriptRoot/../scripts/Create-RdpUser.ps1"

            # Verify that the mocked cmdlets were called as expected
            Should -Invoke 'New-SecureRandomPassword' -Exactly 1
            Should -Invoke 'ConvertTo-SecureString' -Once -WithParameters @{ AsPlainText = $true; Force = $true }
            Should -Invoke 'New-LocalUser' -Once -WithParameters @{ Name = 'RDP'; Password = 'a_very_secure_string'; AccountNeverExpires = $true }
            Should -Invoke 'Add-LocalGroupMember' -Exactly 2
            Should -Invoke 'Add-LocalGroupMember' -Once -WithParameters @{ Group = 'Administrators'; Member = 'RDP' }
            Should -Invoke 'Add-LocalGroupMember' -Once -WithParameters @{ Group = 'Remote Desktop Users'; Member = 'RDP' }

            # Verify the outputs were set correctly
            $script:outputtedCommands | Should -Contain '::set-output name=rdp_user::RDP'
            $script:outputtedCommands | Should -Contain '::set-output name=rdp_password::Password123!@#$'
        }

        It 'should write an error if user creation fails' {
            Mock New-LocalUser { throw "User creation failed" } -Verifiable
            Mock Write-Error { } -Verifiable

            # Use a try/catch block because the script calls 'exit 1'
            try { . "$PSScriptRoot/../scripts/Create-RdpUser.ps1" } catch { }

            Should -Invoke 'Write-Error' -Exactly 1
        }
    }
}
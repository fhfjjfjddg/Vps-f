# tests/Pester.Tests.ps1

# Determine the path to the scripts directory relative to the test file
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptsPath = Join-Path -Path $scriptRoot -ChildPath "..\\scripts"

# Import the functions from the PowerShell scripts to be tested
. (Join-Path -Path $scriptsPath -ChildPath "setup-rdp.ps1")
. (Join-Path -Path $scriptsPath -ChildPath "provision.ps1")
. (Join-Path -Path $scriptsPath -ChildPath "create-provisioning-task.ps1")

Describe "RDP Automation Scripts" {
    Context "setup-rdp.ps1" {
        It "should define the 'Setup-RDP' function" {
            (Get-Command Setup-RDP -ErrorAction SilentlyContinue) | Should -Not -BeNull
        }
    }

    Context "provision.ps1" {
        It "should define the 'Provision-System' function" {
            (Get-Command Provision-System -ErrorAction SilentlyContinue) | Should -Not -BeNull
        }
    }

    Context "create-provisioning-task.ps1" {
        It "should define the 'Create-ProvisioningTask' function" {
            (Get-Command Create-ProvisioningTask -ErrorAction SilentlyContinue) | Should -Not -BeNull
        }
    }
}
# Disable Hyper-V if enabled
$hv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
if ($hv.State -eq "Enabled") {
    Write-Host "Hyper-V is enabled, disabling..."
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
} else {
    Write-Host "Hyper-V is already disabled"
}

# Enable Virtual Machine Platform and Hypervisor Platform
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart

# Install BlueStacks emulator
winget install -e --id BlueStacks.BlueStacks --accept-package-agreements --accept-source-agreements

Write-Host "Emulator support configuration applied successfully."
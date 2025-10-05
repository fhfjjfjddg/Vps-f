# scripts/provision.ps1

function Provision-System {
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
    winget install -e --id BlueStacks.BlueStacks --source winget --locale en-US --accept-package-agreements --accept-source-agreements

    # Install/Upgrade Google Chrome
    if (-not (winget list --id Google.Chrome)) {
        winget install -e --id Google.Chrome --source winget --locale en-US --accept-package-agreements --accept-source-agreements
    } else {
        winget upgrade -e --id Google.Chrome --source winget --locale en-US --accept-package-agreements --accept-source-agreements
    }

    # Upgrade Microsoft Edge
    winget upgrade -e --id Microsoft.Edge --source winget --locale en-US --accept-package-agreements --accept-source-agreements

    # Install or Upgrade WSL
    if (-not (wsl --status)) {
        Write-Host "WSL not found, installing..."
        wsl --install --no-launch
    }
    wsl --update
    wsl --set-default-version 2

    if (-not (wsl -l -q | Select-String "Ubuntu")) {
        wsl --install -d Ubuntu
    }
    wsl --status

    # Unregister the scheduled task to ensure it only runs once
    Unregister-ScheduledTask -TaskName "ProvisionSystem" -Confirm:$false
}

Provision-System
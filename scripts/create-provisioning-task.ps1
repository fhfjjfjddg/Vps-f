# scripts/create-provisioning-task.ps1
$ErrorActionPreference = 'Stop'

function Create-ProvisioningTask {
    $taskName = "ProvisionSystem"
    $scriptPath = "$($env:GITHUB_WORKSPACE)\\scripts\\provision.ps1"
    $taskUser = "BUILTIN\\Users"

    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $principal = New-ScheduledTaskPrincipal -GroupId $taskUser -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Days 1)

    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force
}

Create-ProvisioningTask
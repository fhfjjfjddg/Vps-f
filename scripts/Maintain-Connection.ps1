param(
    [string]$TailscaleIp,
    [string]$RdpUser,
    [string]$RdpPassword
)

if (-not $TailscaleIp -or -not $RdpUser -or -not $RdpPassword) {
    Write-Error "One or more required parameters (TailscaleIp, RdpUser, RdpPassword) were not provided."
    exit 1
}

Write-Host "`n=== RDP ACCESS ==="
Write-Host "Address: $TailscaleIp"
Write-Host "Username: $RdpUser"
Write-Host "Password: $RdpPassword"
Write-Host "==================`n"

# This loop keeps the workflow alive for the RDP session.
while ($true) {
    Write-Host "[$(Get-Date)] RDP session is active. Use Ctrl+C in the GitHub Actions UI to terminate the workflow."
    Start-Sleep -Seconds 300
}
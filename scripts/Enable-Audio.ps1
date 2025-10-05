# Ensure Windows Audio service is enabled and running
Set-Service -Name "Audiosrv" -StartupType Automatic
Start-Service -Name "Audiosrv"

# Update all system drivers to latest available
pnputil /scan-devices
pnputil /update-driver * /install

Write-Host "Audio support enabled and drivers updated."
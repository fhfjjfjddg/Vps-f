# Ensure WSL is installed
if (-not (wsl --status)) {
    Write-Host "WSL not found, installing..."
    wsl --install --no-launch
}

# Update WSL kernel and set default to WSL 2
wsl --update
wsl --set-default-version 2

# Optional: install Ubuntu distro if not exists
if (-not (wsl -l -q | Select-String "Ubuntu")) {
    wsl --install -d Ubuntu
}

# Verify WSL status
wsl --status

Write-Host "WSL installation/upgrade completed successfully."
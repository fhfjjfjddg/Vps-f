# Disable the msstore source to prevent interactive agreement prompts on the runner
winget source disable msstore

winget install -e --id Tailscale.Tailscale --accept-package-agreements --accept-source-agreements

Write-Host "Tailscale installed successfully."
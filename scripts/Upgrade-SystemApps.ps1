# Disable the msstore source to prevent interactive agreement prompts on the runner
winget source disable msstore

# Upgrade all packages
winget upgrade --all --accept-package-agreements --accept-source-agreements

# Ensure Google Chrome is installed or upgraded
if (-not (winget list --id Google.Chrome)) {
  winget install -e --id Google.Chrome --accept-package-agreements --accept-source-agreements
} else {
  winget upgrade -e --id Google.Chrome --accept-package-agreements --accept-source-agreements
}

# Upgrade Edge to latest version
winget upgrade -e --id Microsoft.Edge --accept-package-agreements --accept-source-agreements

Write-Host "System apps and browsers upgraded successfully."
param(
    [string]$AuthKey,
    [string]$RunId
)

# Construct the hostname for the Tailscale connection
$hostname = "gh-runner-$RunId"
Write-Host "Connecting to Tailscale with hostname: $hostname"

# Execute the Tailscale up command
& "$env:ProgramFiles\Tailscale\tailscale.exe" up --authkey=$AuthKey --hostname=$hostname

# Retry logic to get the Tailscale IP address
$tsIP = $null
$retries = 0
$maxRetries = 10
while (-not $tsIP -and $retries -lt $maxRetries) {
    $tsIP = & "$env:ProgramFiles\Tailscale\tailscale.exe" ip -4
    if (-not $tsIP) {
        Write-Host "Tailscale IP not yet available. Retrying in 5 seconds... (Attempt $($retries + 1)/$maxRetries)"
        Start-Sleep -Seconds 5
        $retries++
    }
}

# Check if an IP was assigned and set the output
if (-not $tsIP) {
    Write-Error "Tailscale IP not assigned after multiple retries. Exiting."
    exit 1
}

# Correctly set the output parameter for the workflow
echo "::set-output name=tailscale_ip::$tsIP"
Write-Host "Tailscale connection established successfully. IP: $tsIP"
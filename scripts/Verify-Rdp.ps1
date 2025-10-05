param(
    [string]$TailscaleIp
)

if (-not $TailscaleIp) {
    Write-Error "Tailscale IP was not provided. Cannot verify RDP connection."
    exit 1
}

Write-Host "Verifying RDP accessibility to Tailscale IP: $TailscaleIp"

try {
    $testResult = Test-NetConnection -ComputerName $TailscaleIp -Port 3389 -ErrorAction Stop
    if (-not $testResult.TcpTestSucceeded) {
        # This part of the condition might not be reached if Test-NetConnection throws an error,
        # but it's good practice to have it.
        Write-Error "TCP connection to RDP port 3389 on $TailscaleIp failed."
        exit 1
    }
    Write-Host "TCP connectivity to RDP port successful!"
}
catch {
    Write-Error "An error occurred while testing the network connection to $TailscaleIp:3389. Error: $_"
    exit 1
}
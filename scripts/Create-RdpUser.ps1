# Function to generate a secure random password. This is more complex than the original
# to ensure it meets typical complexity requirements and is highly testable.
function New-SecureRandomPassword {
    param(
        [int]$Length = 16,
        [int]$NonAlphanumericChars = 4
    )
    # Use the System.Web.Security assembly for a robust password generator
    Add-Type -AssemblyName System.Web
    return [System.Web.Security.Membership]::GeneratePassword($Length, $NonAlphanumericChars)
}

$password = New-SecureRandomPassword

try {
    # Create the user with the generated password
    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name "RDP" -Password $securePass -AccountNeverExpires -ErrorAction Stop

    # Add the user to the required groups
    Add-LocalGroupMember -Group "Administrators" -Member "RDP" -ErrorAction Stop
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member "RDP" -ErrorAction Stop

    # Correctly set the output parameters for subsequent steps in the workflow
    echo "::set-output name=rdp_user::RDP"
    echo "::set-output name=rdp_password::$password"

    Write-Host "RDP user created successfully and outputs set."
} catch {
    Write-Error "Failed to create RDP user. Error: $_"
    exit 1
}
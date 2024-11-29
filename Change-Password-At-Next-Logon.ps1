<#
    .SYNOPSIS
    Forces all local users to change their password at the next logon.

    .DESCRIPTION
    This script iterates over all local user accounts and enforces the "Change password at next logon" policy. 
    It works for both standard users and administrators. Excluded system accounts (such as Guest and DefaultAccount) 
    are not affected. The script also updates local group policies to enforce password complexity and minimum length.

    .PARAMETER None
    This script does not require any parameters. It affects all local user accounts.

    .EXAMPLE
    .\Change-Password-At-Next-Logon.ps1
    This example shows how to run the script with default settings.

    .NOTES
    filename:   Change-Password-At-Next-Logon.ps1
    author:     Prabin A T / prabinattupurathu@gmail.com
    Created:    11/29/2024
    Updated:    See GitHub for latest version
    disclaimer: This script is provided as-is. Use at your own risk. Always test in a controlled environment before deploying in production.

#>

# List all local users
$users = Get-LocalUser

# Loop through each user and configure password change on next logon
foreach ($user in $users) {
    try {
        # Ensure the account is not excluded (like system accounts) 
        if ($user.Name -notin @("Guest", "WDAGUtilityAccount", "DefaultAccount", "localservice", "networkservice")) {
            # Force password change at next logon for all users, including administrators
            net user $user.Name /logonpasswordchg:yes
        }
    } catch {
        # Log errors to a file
        $errorMessage = "Error processing user $($user.Name): $_"
        Add-Content -Path "C:\error_log.txt" -Value $errorMessage
    }
}

# Update group policy for password complexity and minimum length
try {
    # Export current security settings to a temporary file
    secedit.exe /export /cfg "C:\temp_secsettings.inf"

    $policyFilePath = "C:\temp_secsettings.inf"

    # Ensure the policy file exists
    if (Test-Path $policyFilePath) {
        # Update the policy file for password requirements
        (Get-Content $policyFilePath) -replace 'MinimumPasswordLength = \d+', 'MinimumPasswordLength = 12' |
        ForEach-Object { $_ -replace 'PasswordComplexity = \d+', 'PasswordComplexity = 1' } |
        Set-Content -Path $policyFilePath

        # Apply the updated settings
        secedit.exe /configure /db secedit.sdb /cfg $policyFilePath /areas SECURITYPOLICY

        # Refresh group policy settings
        gpupdate /force

        # Cleanup the temporary policy file
        Remove-Item $policyFilePath -Force
    } else {
        Write-Host "Error: Security policy file not found. Unable to update password settings."
    }
} catch {
    # Log errors related to group policy updates
    $errorMessage = "Error updating group policy: $_"
    Add-Content -Path "C:\error_log.txt" -Value $errorMessage
}

# Remove secedit.sdb and secedit.jfm created in the current PowerShell run folder
try {
    $currentDir = Get-Location

    $seceditDbPath = Join-Path $currentDir "secedit.sdb"
    $seceditJfmPath = Join-Path $currentDir "secedit.jfm"

    # Check if the files exist and remove them
    if (Test-Path $seceditDbPath) {
        Remove-Item $seceditDbPath -Force
    }

    if (Test-Path $seceditJfmPath) {
        Remove-Item $seceditJfmPath -Force
    }

} catch {
    # Log errors if any files can't be deleted
    $errorMessage = "Error deleting secedit files: $_"
    Add-Content -Path "C:\error_log.txt" -Value $errorMessage
}

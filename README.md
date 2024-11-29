# Windows Scripts

A collection of PowerShell scripts designed to help system administrators manage and automate tasks on Windows machines. These scripts focus on common administrative functions, user management, and security enhancements.

## Available Scripts

### 1. **Change-Password-At-Next-Logon.ps1**
   - **Description**: Forces all local users and administrators to change their password at the next logon, excluding system accounts (e.g., Guest, DefaultAccount). It also resets the password to a temporary one and enforces strong password policies.
   - **How to Use**:
     - Download or clone the repository.
     - Open PowerShell as Administrator.
     - Run the script by executing:
       ```powershell
       .\Change-Password-At-Next-Logon.ps1
       ```
## Requirements

- PowerShell 5.1 or higher.
- Administrator privileges for most scripts.
- Windows 10 or Server 2016/2019/2022 environments.

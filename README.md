# FixDomainTrust

PowerShell script that checks and automatically repairs domain trust issues.

## Features
- Creates a scheduled task at startup  
- Logs results to `C:\Support\domain-trust.log`  
- Resets machine password against a specified Domain Controller if trust is broken  

## Usage

1. **Export credentials** (run once on the device):
   ```powershell
   $cred = Get-Credential
   $cred | Export-Clixml -Path "C:\Support\domain-admin.xml"

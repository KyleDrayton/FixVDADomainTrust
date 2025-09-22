<#
.SYNOPSIS
    Automatically checks and repairs domain trust issues on a Windows device.

.DESCRIPTION
    - Exports domain admin credentials (to be sanitized before use in production)
    - Creates a startup scheduled task that runs the trust check script
    - If domain trust is broken, resets the machine password using stored credentials
    - Logs results to C:\Support\domain-trust.log

.NOTES
    Author: Kyle Drayton
    GitHub: https://github.com/kyledrayton
#>

#### Create Cred on target device
$cred = Get-Credential
$cred | Export-Clixml -Path "C:\Support\domain-admin.xml"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$credPath = "C:\Support\domain-admin.xml"
$log = "C:\Support\domain-trust.log"
$taskName = "FixDomainTrust"

Start-Transcript -Path $log -Append

if (-not (Test-ComputerSecureChannel)) {
    Write-Host "[$(Get-Date)] Trust broken. Attempting to reset password..."
    try {
        $cred = Import-Clixml $credPath
        Reset-ComputerMachinePassword -Server <DomainControllerFQDN> -Credential $cred
        Write-Host "[$(Get-Date)] Password reset succeeded."
    } catch {
        Write-Host "[$(Get-Date)] Password reset failed: $_"
    }
} else {
    Write-Host "[$(Get-Date)] Trust is healthy."
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Create Scheduled Task
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\Support\CheckAndFixDomainTrust.ps1"'
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal

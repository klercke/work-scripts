# File: enable-litiagtion-hold-on-all-mailboxes.ps1
# Version: v1.1.0
# Author: Konnor Klercke

if (-Not(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "ExhangeOnlineManagement module is missing. Please see https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps#install-and-maintain-the-exchange-online-powershell-module"
}

Write-Host "Enter the email address of an admin account on the tenant you would like connect to:"
$login = Read-Host -Prompt "login"
Try {
    Connect-ExchangeOnline -UserPrincipalName $login
}
Catch {
    Write-Host "Failed to authenticate. Make sure there are no typos or leading/trailing spaces in the login name."
    Exit
}
$orginfo = Get-OrganizationConfig | Select-Object Name, Identity

Write-Host "Enter the duration of the litigation hold in days. Enter -1 for unlimited."
$duration = Read-Host -Prompt "hold duration"
if ($duration -eq "-1") {
    $duration = "unlimited"
}
else {
    try {
        [int]$duration
    }
    catch {
        Write-Host "Error: Could not interpret input. Please enter a positive integer or -1."
        Exit
    }
}

Write-Host "You are enabling a litigation hold on all user mailboxes in the $($orginfo.Name) ($($orginfo.Identity)) tenant. Type `"y`" to confirm."
$confirm = Read-Host
if ($confirm -eq "y") {
    
    Get-Mailbox -ResultSize unlimited -Filter {(RecipientTypeDetails -eq 'UserMailbox') -and (Alias -ne 'Admin')} | Set-Mailbox -LitigationHoldEnabled:$true -LitigationHoldDuration $duration -WarningAction SilentlyContinue
    Write-Host "Done!"
}
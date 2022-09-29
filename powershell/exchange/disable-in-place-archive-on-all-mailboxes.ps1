# File: disable-in-place-archive-on-all-mailboxes.ps1
# Version: v1.0.0
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

Write-Host "You are removing the in-place archive for all user mailboxes in the $($orginfo.Name) ($($orginfo.Identity)) tenant. Type `"y`" to confirm."
$confirm = Read-Host
if ($confirm -eq "y") {
    Get-Mailbox -ResultSize unlimited -Filter {(RecipientTypeDetails -eq 'UserMailbox') -and (Alias -ne 'Admin')} | Disable-Mailbox -Archive -Confirm:$false
    Write-Host "Done!"
}
# File: remove-admin-on-all-mailboxes.ps1
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

Write-Host "Enter the email of the account that will lose access to all mailboxes."
$stop = $false
While (!($stop)){
    $admin = Read-Host -Prompt "admin email"
    Try {
        Get-Mailbox $admin -ErrorAction Stop | Out-Null
        $stop = $true
    }
    Catch {
        Write-Host "Error checking mailbox. Please enter an account that exists within the $($orginfo.Name) ($($orginfo.Identity)) tenant."
    }
}

Write-Host "You are removing the ability for user $($admin) access to all user mailboxes in the $($orginfo.Name) ($($orginfo.Identity)) tenant. They will retain full control of their own mailbox. Type `"y`" to confirm."
$confirm = Read-Host
if ($confirm -eq "y") {
    ($save = Get-Mailbox $admin | Select-Object Alias) | out-null
    Get-Mailbox -ResultSize unlimited -Filter {(RecipientTypeDetails -eq 'UserMailbox') -and (Alias -ne "$($save.Alias)")} | Remove-MailboxPermission -User $admin -AccessRights fullaccess -InheritanceType all -Confirm:$false
    Write-Host "Done!"
}
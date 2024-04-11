# File: hard-link-user.ps1
# Version: v1.0.0
# Author: Konnor Klercke

# Script options
[cmdletbinding()]
param(
    [Parameter(HelpMessage="User principal name", Mandatory=$true)]
    [string]$UserUpn
)

# Connect to Graph
Connect-MgGraph -Scopes user.readwrite.all

# Get user's GUID
$ADUser = Get-ADUser -Filter "UserPrincipalName -eq '$UserUpn'" -Properties mS-DS-ConsistencyGUID
$Guid = [guid]($ADUser.objectGUID)

# Format GUID
$GuidAsByteArray = $Guid.ToByteArray()
$ImmutableId = [System.Convert]::ToBase64String($GuidAsByteArray)

# Set ms-Ds-ConsistencyGuid for the user
Set-AdUser $ADUser -Replace @{ "ms-Ds-ConsistencyGuid" = $ImmutableId }

# Get Entra user
$EntraUser = Get-MgUser -Filter "UserPrincipalName eq '$UserUpn'"

# Set Entra user UPN
Update-MgUser -UserId $EntraUser.Id -OnPremisesImmutableId $ImmutableId

# Let the user know the link was successful
Write-Host "Successfully updated $UserUpn. ms-DS-ConsistencyGuid = ""$ImmutableId"""

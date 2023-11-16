# File: duo-sso-preflight.ps1
# Version: v0.1.0
# Author: Konnor Klercke
# Note: This script is not optimized. It could (and will) be made faster.

# Script options
[cmdletbinding()]
param(
    [Parameter(HelpMessage="Filename of user data CSV to import", Mandatory=$true)]
    [string]$UserCsv,

    [Parameter(HelpMessage="Export only users whose accounts are flagged as problematic")]
    [bool]$ExportOnlyProblematicUsers = $false,
    
    [Parameter(HelpMessage="Output filename")]
    [string]$OutFile = "",

    [Parameter(HelpMessage="Verbose outfile")]
    [bool]$VerboseExport = $false,

    [Parameter(HelpMessage="Disconnect from Graph after running")]
    [bool]$DisconnectFromGraph = $true
)

# Check For required modules
Write-Host ""
if (-Not(Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "The ActiveDirectory module is missing. Please see https://learn.microsoft.com/en-us/powershell/module/activedirectory/"
    Read-Host "Press Enter to exit"
    Exit
}
Import-Module ActiveDirectory
if (-Not(Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "The Microsoft Graph module is missing. Please see https://learn.microsoft.com/en-us/powershell/module/microsoftgraph/"
    Read-Host "Press Enter to exit"
    Exit
}
Import-Module Microsoft.Graph.Users

# Define User class
class User {
    [string]        $LastName
    [string]        $FirstName
    [mailaddress]   $EmailAddress
    [string]        $OnPremUPN
    [string]        $EntraUPN
    [array]         $ConsistencyGUID
    [string]        $Note

    User(
        [string]$LastName,
        [string]$FirstName,
        [mailaddress]$EmailAddress
    ) {
        $this.LastName = $LastName
        $this.FirstName = $FirstName
        $this.EmailAddress = $EmailAddress
        $this.Note = ""
    }

    # Update note to include reasons why this user may not be compliant
    [void] UpdateNote([string] $TextToAdd) {
        if ($this.Note -eq "") {
            $this.Note = $TextToAdd
        }
        else {
            $this.Note += (', ' + $TextToAdd)
        }
    }
}

# Connect to Entra ID
Write-Host "Please sign in to Entra ID with an account that has User.Read.All permissions"
Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

# Import users into an array of Users
Write-Host "Importing users from CSV..."
$UsersFromCsv = Import-Csv -Path $UserCsv
$Users = @()
ForEach ($User in $UsersFromCsv) {
    $UserObject = @([User]::new($User."LastName", $User."FirstName", $User."Email"))
    $Users += $UserObject
}
$UserCount = $Users.Length
$Users = $Users | Sort-Object -Property LastName
Write-Host "Imported $UserCount users." 

# Find email domain
$EmailDomain = ([mailaddress]$Users[0].EmailAddress).Host
$EmailDomainConfirmed = ""
While ($EmailDomainConfirmed.ToLower() -ne "y") {
    Write-Host "Is $EmailDomain the email domain that will be federated?"
    if (!($EmailDomainConfirmed = Read-Host "Email domain correct? [Y/n]")) {$EmailDomainConfirmed = "y"}


    if ($EmailDomainConfirmed.ToLower() -eq "n" ) {
        Write-Host "Please enter the correct email domain WITHOUT the leading @ (ex. contoso.com):"
        $EmailDomain = Read-Host "Email domain"
    }
}

# Check email address for each user and append "Incorrect email domain" to their notes if it is incorrect 
Write-Host "Checking to make sure all users are on the correct email domain..."
$FailedEmailDomainCount = 0
ForEach ($User in $Users) {
    $UserEmailDomain = ([mailaddress]$User.EmailAddress).Host
    if ($UserEmailDomain -ne $EmailDomain) {
        $User.UpdateNote("Incorrect email domain")
        $FailedEmailDomainCount++
    }
}
Write-Host "Found $FailedEmailDomainCount users with the incorrect email domain."

# Check AD accounts
# TODO: Check for users by real name
Write-Host "Checking AD..."
Write-Host "Checking via sAMAccountName..."
$ADDomain = Get-ADDomain
$FailedSamAccountCount = 0
$NoConsistencyGuidCount = 0
$NoEmailSetCount = 0
$EmailIncorrectCount = 0
ForEach ($User in $Users) {
    [Microsoft.ActiveDirectory.Management.ADAccount] $OnPremUser = Get-AdUser -SearchBase $ADDomain.DistinguishedName -Server $ADDomain.PDCEmulator -Property "mS-DS-ConsistencyGUID", Mail -Filter "SamAccountName -eq '$(([mailaddress]$User.EmailAddress).User)'"
    if ($OnPremUser -eq $()) {
        # User was not found in AD
        $User.UpdateNote("sAMAccountName not found")
        $FailedSamAccountCount++
    }
    else {
        $User.OnPremUPN = $OnPremUser.UserPrincipalName
        if (!$OnPremUser.'mS-DS-ConsistencyGUID') {
            # User can not sign in with Duo SSO if this is not set
            $User.UpdateNote("mS-DS-ConsistencyGUID not set")
            $NoConsistencyGuidCount++
        }
        else {
            $User.ConsistencyGUID = $OnPremUser.'mS-DS-ConsistencyGUID'
        }
        # Make sure user has email set
        if (!$OnPremUser.Mail) {
            $User.UpdateNote("AD mail attribute not set")
            $NoEmailSetCount++
        }
        else {
            # Make sure the email is correct
            if ($OnPremUser.Mail -ne $User.EmailAddress) {
                $User.UpdateNote("AD mail attribute incorrect")
                $EmailIncorrectCount++
            }
        }
    }
}
Write-Host "$FailedSamAccountCount users could not be found by sAMAccountName"
Write-Host "$NoConsistencyGuidCount users do not have mS-DS-ConsistencyGUID set"
Write-Host "$NoEmailSetCount users do not have an email set in AD"
Write-Host "$EmailIncorrectCount users have the wrong email set in AD"

# Check Entra ID Users
# TODO: Add additional checks using other attributes. e.g. for users not found by ImmutableId, try to find them by email or full name
Write-Host "Checking Entra..."
Write-Host "Checking via mS-DS-ConsistencyGUID..."
$UsersNotInEntraByGUID = 0
foreach ($User in ($Users | Where-Object ConsistencyGUID)) {
    $ImmutableId = [system.convert]::ToBase64String(([GUID]$User.ConsistencyGUID).ToByteArray())
    $EntraUser = Get-MgUser -Filter "onPremisesImmutableId eq '$ImmutableId'"
    if ($EntraUser) {
        $User.EntraUPN = $EntraUser.UserPrincipalName
    }
    else {
        $User.UpdateNote("Could not find Entra user by onPremisesImmutableId")
        $UsersNotInEntraByGUID++
    }
}
Write-Host "$UsersNotInEntraByGUID could not be found in Entra by ImmutableId"

# Export users to CSV
if ($OutFile -eq "") { $OutFile = "./Duo-Preflight-$($EmailDomain.Replace('.', '-')).csv" }
if ($VerboseExport) {
    if ($ExportOnlyProblematicUsers) {
        Write-Host "Exporting all users who may have account issues to $OutFile..."
        $Users |
            Where-Object Note -ne "" | 
            Select-Object LastName, FirstName, EmailAddress, EntraUPN, OnPremUPN, @{Label='ConsistencyGUID'; Expression={$_.ConsistencyGUID -join '-'}}, Note |
            Export-Csv -Path $OutFile 
    }
    else {
        Write-Host "Exporting all users to $OutFile..."
        $Users | 
            Select-Object LastName, FirstName, EmailAddress, EntraUPN, OnPremUPN, @{Label='ConsistencyGUID'; Expression={$_.ConsistencyGUID -join '-'}}, Note |
            Export-Csv -Path $OutFile 
    }
}
else {
    if ($ExportOnlyProblematicUsers) {
        Write-Host "Exporting all users who may have account issues to $OutFile..."
        $Users |
            Where-Object Note -ne "" | 
            Select-Object LastName, FirstName, EmailAddress, Note |
            Export-Csv -Path $OutFile 
    }
    else {
        Write-Host "Exporting all users to $OutFile..."
        $Users | 
            Select-Object LastName, FirstName, EmailAddress, Note |
            Export-Csv -Path $OutFile 
    }
}

if ($DisconnectFromGraph) { Disconnect-MgGraph | Out-Null }
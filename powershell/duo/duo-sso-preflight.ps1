# File: duo-sso-preflight.ps1
# Version: v0.2.0
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
Write-Output ""
if (-Not(Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Output "The ActiveDirectory module is missing. Please see https://learn.microsoft.com/en-us/powershell/module/activedirectory/"
    Read-Host "Press Enter to exit"
    Exit
}
Import-Module ActiveDirectory
if (-Not(Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Output "The Microsoft Graph module is missing. Please see https://learn.microsoft.com/en-us/powershell/module/microsoftgraph/"
    Read-Host "Press Enter to exit"
    Exit
}
Import-Module Microsoft.Graph.Users

# User errors enum
# Note that the binary representations are not necessarily correct.
# For example, Powershell (as of v7.4.0) will interpret 0b1000000000000000 as -32768
# https://github.com/PowerShell/PowerShell/issues/19218
[Flags()] enum UserError {
    NoError = 0

    # Email errors
    EmailDomainIncorrectError     = 1    # 0b0001
    EmailAttributeEmptyError      = 2    # 0b0010
    EmailAttributeIncorrectError  = 4    # 0b0100
    # Reserved                    = 8    # 0b1000

    # AD lookup errors
    ADSearchAccountNameError  = 16    # 0b00010000
    ADSearchRealNameError     = 32    # 0b00100000
    # Reserved                = 64    # 0b01000000
    # Reserved                = 128   # 0b10000000

    # Entra connect errors
    ConnectConsistencyGuidMissingErorr = 256   # 0b000100000000
    # Reserved                         = 512   # 0b001000000000
    # Reserved                         = 1024  # 0b010000000000
    # Reserved                         = 2048  # 0b100000000000

    # Entra account errors
    EntraSearchImmutableIdError  = 4096  # 0b0001000000000000
    EntraSearchEmailError        = 8192  # 0b0010000000000000
    EntraSearchRealNameError     = 16384 # 0b0100000000000000
    # Reserved                   = 32769 # 0b1000000000000000
}

# User error "localizations"
# UserErrorDescriptions[UserError] = String
$UserErrorDescriptions = @{
    # Email errors
    [UserError]::EmailDomainIncorrectError      = "Email domain does not match"
    [UserError]::EmailAttributeEmptyError       = "AD email attribute empty"
    [UserError]::EmailAttributeIncorrectError   = "AD email attribute does not match provided email"
    
    # AD lookup errors
    [UserError]::ADSearchAccountNameError  = "Could not find user in AD when searching by username"
    [UserError]::ADSearchRealNameError     = "Could not find user in AD when searching by real name"

    # Entra connect errors
    [UserError]::ConnectConsistencyGuidMissingErorr    = "AD mS-DS-ConsistencyGUID attribute empty"

    # Entra account errors
    [UserError]::EntraSearchImmutableIdError = "Could not find user in Entra when searching by ImmutableId"
    [UserError]::EntraSearchEmailError       = "Could not find user in Entra when searching by email address"
    [UserError]::EntraSearchRealNameError    = "Could not find user in Entra when searching by real name"
}

# Define User class
class User {
    [string]        $LastName
    [string]        $FirstName
    [mailaddress]   $EmailAddress
    [string]        $OnPremUPN
    [string]        $EntraUPN
    [array]         $ConsistencyGUID
    [string]        $Note
    [UserError]     $ErrorCode

    User (
        [string]$LastName,
        [string]$FirstName,
        [mailaddress]$EmailAddress
    ) {
        $this.LastName = $LastName
        $this.FirstName = $FirstName
        $this.EmailAddress = $EmailAddress
        $this.Note = ""
        $this.ErrorCode = [UserError]::NoError
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

    [void] UpdateError([UserError] $ErrorToAdd) {
        $this.ErrorCode += $ErrorToAdd

        $this.UpdateNote($Global:UserErrorDescriptions[$ErrorToAdd])
    }
}

# Connect to Entra ID
Write-Output "Please sign in to Entra ID with an account that has User.Read.All permissions"
Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

# Import users into an array of Users
Write-Output "Importing users from CSV..."
$UsersFromCsv = Import-Csv -Path $UserCsv
$Users = @()
ForEach ($User in $UsersFromCsv) {
    $UserObject = @([User]::new($User."LastName", $User."FirstName", $User."Email"))
    $Users += $UserObject
}
$UserCount = $Users.Length
$Users = $Users | Sort-Object -Property LastName
Write-Output "Imported $UserCount users." 

# Find email domain
$EmailDomain = ([mailaddress]$Users[0].EmailAddress).Host
$EmailDomainConfirmed = ""
While ($EmailDomainConfirmed.ToLower() -ne "y") {
    Write-Output "Is $EmailDomain the email domain that will be federated?"
    if (!($EmailDomainConfirmed = Read-Host "Email domain correct? [Y/n]")) {$EmailDomainConfirmed = "y"}


    if ($EmailDomainConfirmed.ToLower() -eq "n" ) {
        Write-Output "Please enter the correct email domain WITHOUT the leading @ (ex. contoso.com):"
        $EmailDomain = Read-Host "Email domain"
    }
}

# Check email address for each user and append "Incorrect email domain" to their notes if it is incorrect 
Write-Output "Checking to make sure all users are on the correct email domain..."
$FailedEmailDomainCount = 0
ForEach ($User in $Users) {
    $UserEmailDomain = ([mailaddress]$User.EmailAddress).Host
    if ($UserEmailDomain -ne $EmailDomain) {
        $User.UpdateError([UserError]::EmailDomainIncorrectError)
        $FailedEmailDomainCount++
    }
}
Write-Output "Found $FailedEmailDomainCount users with the incorrect email domain."

# Check AD accounts
Write-Output "Checking AD..."
Write-Output "Checking via sAMAccountName..."
$ADDomain = Get-ADDomain
$FailedSamAccountCount = 0
$FailedRealNameCount = 0
$NoConsistencyGuidCount = 0
$NoEmailSetCount = 0
$EmailIncorrectCount = 0
ForEach ($User in $Users) {
    $p = @{ 
        'SearchBase' = $ADDomain.DistinguishedName;
        'Server' = $ADDomain.PDCEmulator;
        'Property' = "mS-DS-ConsistencyGUID", 'Mail';
        'Filter' = "SamAccountName -eq '$(([mailaddress]$User.EmailAddress).User)'"
        }
    [Microsoft.ActiveDirectory.Management.ADAccount] $OnPremUser = Get-ADUser @p
    if ($OnPremUser -eq $()) {
        # User could not be found by username
        $User.UpdateError([UserError]::ADSearchAccountNameError)
        $FailedSamAccountCount++

        # Try to find the user by looking up their real name
        $p = @{
            'SearchBase' = $ADDomain.DistinguishedName;
            'Server' = $ADDomain.PDCEmulator;
            'Property' = "mS-DS-ConsistencyGUID", 'Mail';
            'Filter' = "(GivenName -eq '$($User.FirstName)') -and (Surname -eq '$($User.LastName)')"
        }
        $OnPremuser = Get-ADUser @p
        if ($OnPremUser -eq $()) {
            # User could not be found in AD by real name OR username
            $User.UpdateError([UserError]::ADSearchRealNameError)
            $FailedRealNameCount++
        }
        # Skip this iteration of the loop
        Continue
    }
    $User.OnPremUPN = $OnPremUser.UserPrincipalName
    if (!$OnPremUser.'mS-DS-ConsistencyGUID') {
        # User can not sign in with Duo SSO if this is not set
        $User.UpdateError([UserError]::ConnectConsistencyGuidMissingErorr)
        $NoConsistencyGuidCount++
    }
    else {
        $User.ConsistencyGUID = $OnPremUser.'mS-DS-ConsistencyGUID'
    }
    # Make sure user has email set
    if (!$OnPremUser.Mail) {
        $User.UpdateError([UserError]::EmailAttributeEmptyError)
        $NoEmailSetCount++
    }
    else {
        # Make sure the email is correct
        if ($OnPremUser.Mail -ne $User.EmailAddress) {
            $User.UpdateError([UserError]::EmailAttributeIncorrectError)
            $EmailIncorrectCount++
        }
    }
}
Write-Output "$FailedSamAccountCount users could not be found by sAMAccountName"
Write-Output "`t Of those $FailedSamAccountCount, $FailedRealNameCount could also not be found by real name"
Write-Output "$NoConsistencyGuidCount users do not have mS-DS-ConsistencyGUID set"
Write-Output "$NoEmailSetCount users do not have an email set in AD"
Write-Output "$EmailIncorrectCount users have the wrong email set in AD"

# Check Entra ID Users
# TODO: Add additional checks using other attributes. e.g. for users not found by ImmutableId, try to find them by email or full name
Write-Output "Checking Entra..."
Write-Output "Checking via mS-DS-ConsistencyGUID..."
$UsersNotInEntraByGUIDCount = 0
$UsersNotInEntraByEmailCount = 0
$UsersNotInEntraByDisplayNameCount = 0
foreach ($User in $Users) {
    # This will fail if the user does not have a consistenctyGUID, so we make sure only those users get looked up
    $ImmutableId = "0"
    if ($User.ConsistencyGUID) {
        $ImmutableId = [system.convert]::ToBase64String(([GUID]$User.ConsistencyGUID).ToByteArray())
    }
    $EntraUser = Get-MgUser -Filter "onPremisesImmutableId eq '$ImmutableId'"
    # Check by UPN
    if ($EntraUser) {
        $User.EntraUPN = $EntraUser.UserPrincipalName
    }
    else {
        $User.UpdateError([UserError]::EntraSearchImmutableIdError)
        $UsersNotInEntraByGUIDCount++

        # Check by email
        $EntraUser = Get-MgUser -Filter "Mail eq '$($User.EmailAddress)'"
        if ($EntraUser) {
            $User.EntraUPN = $EntraUser.UserPrincipalName
        }
        else {
            $User.UpdateError([UserError]::EntraSearchEmailError)
            $UsersNotInEntraByEmailCount++

            # Check by real name
            $EntraUser = Get-mguser -filter "DisplayName eq '$($($user.FirstName) + ' ' + $($user.LastName))'"
            if ($EntraUser) {
                $User.EntraUPN = $EntraUser.UserPrincipalName
            }
            else {
                $User.UpdateError([UserError]::EntraSearchRealNameError)
                $UsersNotInEntraByDisplayNameCount++
            }
        }
    }
}
Write-Output "$UsersNotInEntraByGUIDCount could not be found in Entra by ImmutableId"
Write-Output "`t Of those $UsersNotInEntraByGUIDCount, $UsersNotInEntraByEmailCount could also not be found by email"
Write-Output "`t Of those $UsersNotInEntraByEmailCount, $UsersNotInEntraByDisplayNameCount could also not be found by display name"

# Export users to CSV
if ($OutFile -eq "") { $OutFile = "./Duo-Preflight-$($EmailDomain.Replace('.', '-')).csv" }
if ($VerboseExport) {
    if ($ExportOnlyProblematicUsers) {
        Write-Output "Exporting all users who may have account issues to $OutFile..."
        $Users |
            Where-Object Note -ne "" | 
            Select-Object LastName, FirstName, EmailAddress, EntraUPN, OnPremUPN, @{Label='ConsistencyGUID'; Expression={$_.ConsistencyGUID -join '-'}}, @{Label='ErrorCode'; Expression={[uint64]$_.ErrorCode}}, Note |
            Export-Csv -Path $OutFile 
    }
    else {
        Write-Output "Exporting all users to $OutFile..."
        $Users | 
            Select-Object LastName, FirstName, EmailAddress, EntraUPN, OnPremUPN, @{Label='ConsistencyGUID'; Expression={$_.ConsistencyGUID -join '-'}}, @{Label='ErrorCode'; Expression={[uint64]$_.ErrorCode}}, Note |
            Export-Csv -Path $OutFile 
    }
}
else {
    if ($ExportOnlyProblematicUsers) {
        Write-Output "Exporting all users who may have account issues to $OutFile..."
        $Users |
            Where-Object Note -ne "" | 
            Select-Object LastName, FirstName, EmailAddress, @{Label='ErrorCode'; Expression={[uint64]$_.ErrorCode}}, Note |
            Export-Csv -Path $OutFile 
    }
    else {
        Write-Output "Exporting all users to $OutFile..."
        $Users | 
            Select-Object LastName, FirstName, EmailAddress, @{Label='ErrorCode'; Expression={[uint64]$_.ErrorCode}}, Note |
            Export-Csv -Path $OutFile 
    }
}

if ($DisconnectFromGraph) { Disconnect-MgGraph | Out-Null }
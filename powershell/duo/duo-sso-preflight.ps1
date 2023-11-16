# File: duo-sso-preflight.ps1
# Version: v0.1.0
# Author: Konnor Klercke
# Note: This script is not optimized. It could (and will) be made faster.

# Script options
[cmdletbinding()]
param(
    [Parameter(HelpMessage="Filename of user data CSV to import", Mandatory=$true)]
    [string]$UserCsv
)

# Check For required modules
if (-Not(Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "The ActiveDirectory module is missing. Please see https://learn.microsoft.com/en-us/powershell/module/activedirectory/" 
    Read-Host "Press Enter to exit"
    Exit
}

# Define User class
class User {
    [string]        $LastName
    [string]        $FirstName
    [mailaddress]   $EmailAddress
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
}

# Import users into an array of Users
Write-Host "Importing users..."
$UsersFromCsv = Import-Csv -Path $UserCsv
$Users = @()
ForEach ($User in $UsersFromCsv) {
    $UserObject = @([User]::new($User."Last Name", $User."First Name", $User."Email")) 
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
Write-Host "Checking to make sure all users are on the correct email domain..."

# Check email address for each user and append "Incorrect email domain" to their notes if it is incorrect 
ForEach ($User in $Users) {
    $UserEmailDomain = ([mailaddress]$User.EmailAddress).Host
    if ($UserEmailDomain -ne $EmailDomain) {
        $User.Note += "Incorrect email domain"
    }
}
$UsersWithIncorrectEmailDomain = $Users | Where-Object Note -ne ""
Write-Host "Found $($UsersWithIncorrectEmailDomain.Length) users with the incorrect email domain."

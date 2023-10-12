# File: set-consistency-guid.ps1
# Version: v1.0.0
# Author: Konnor Klercke

# Script options
[cmdletbinding()]
param(
    [Parameter(HelpMessage="User login name", Mandatory=$true)]
    [string]$Username
)

# Get user's GUID
$User = Get-ADUser -Identity $Username -Properties mS-DS-ConsistencyGUID
$GUID = $User.ObjectGUID

# Convert GUID to ByteArray, which is what AD is expecting
$GUIDAsByteArray = $GUID.ToByteArray()

# Set ms-Ds-ConsistencyGuid for the user
Set-ADUser $User -Replace @{ "ms-Ds-ConsistencyGuid" = $GUIDAsByteArray }
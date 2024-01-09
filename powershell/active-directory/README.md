# AD Powershell Scripts

These scripts all operate within an Active Directoy environment. You will need to run them on a DC or a machine with ActiveDirectory PowersShell.

## Hybrid Identity

These scripts will manage users in a hybrid (Entra Connect) environment.

### set-consistency-guid.ps1

This script will take a the specified user's existing mS-DS-ConsistencyGUID and Convert the GUID to ByteArray, which is what AD is expecting.

#### Usage

```set-consistency-guid.ps1 -Username [user login name]```

#### Example

```
PS> .\set-consistency-guid.ps1 -Username testuser
Successfully updated testuser. ms-DS-ConsistencyGuid = 35 B4 5A 9F 31 A8 64 48 9F 53 13 54 37 62 C0 DF
```

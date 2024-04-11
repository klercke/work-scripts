# AD Powershell Scripts

These scripts all operate within an Active Directoy environment. You will need to run them on a DC or a machine with ActiveDirectory PowersShell.

## Hybrid Identity

These scripts will manage users in a hybrid (Entra Connect) environment.

### set-consistency-guid.ps1

This script will set the mS-DS-ConsistencyGuid AD attribute for a user.

#### Usage

```set-consistency-guid.ps1 -Username [user login name]```

#### Example

```
PS> .\set-consistency-guid.ps1 -Username testuser
Successfully updated testuser. ms-DS-ConsistencyGuid = 35 B4 5A 9F 31 A8 64 48 9F 53 13 54 37 62 C0 DF
```

### hard-link-user.ps1

This script will generate an immutableId/mS-DS-ConsistencyGuid for a given user and update the attribute both in AD and Entra.

#### Usage

```hard-link-user.ps1 -UserUpn [UserPrincipalName]```

#### Example

```
PS> .\hard-link-user.ps1 -UserUpn "testuser@contoso.com"
Successfully updated testuser@contoso.com. ms-DS-ConsistencyGuid = "//SffdfKZkYnrBC7ueqTFg=="
```

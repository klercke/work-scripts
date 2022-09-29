# Exchange PowerShell Scripts

These scripts all operate within an Exchange Online session and therefore require the ExchangeOnlineManagement module.

## User Management

These scripts will iterate over every user in the tenant in one way or another to perform bulk operations.

### make-admin-on-all-mailboxes.ps1

#### Description

This script will connect to a specified Exchange online session and give the specified user full access to all user mailboxes in that Exchange tenant.

#### Usage

```make-admin-on-all-mailboxes.ps1```

#### Example

```
PS > .\make-admin-on-all-mailboxes.ps1
Enter the email address of an admin account on the tenant you would like connect to:
login: admin@contoso.com
Enter the email of the account that will have full access to all mailboxes. It is HIGHLY recommended that this is a dedicated admin account.
admin email: admin@contoso.com
You are granting the user admin@contoso.com access to all user mailboxes in the contoso.com (contoso.com) tenant. Type "y" to confirm
y

Identity             User                 AccessRights                                                                                                                                                                                IsInherited Deny
--------             ----                 ------------                                                                                                                                                                                ----------- ----
5v1r1c               NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
MiriamG              NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
IsaiahL              NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
GradyA               NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
PattiF               NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
AlexW                NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
JoniS                NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
AdeleV               NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
LeeG                 NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
LynneR               NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
HenriettaM           NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
PradeepG             NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
JohannaL             NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
MeganB               NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
NestorW              NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
DiegoS               NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
LidiaH               NAMP222A002\$7JOU40… {FullAccess}                                                                                                                                                                                False       False
```

### remove-admin-on-all-mailboxes.ps1

#### Description

This script will connect to a specified Exchange online session and remove full access to all user mailboxes in that Exchange tenant from a specified user, while retaining their full control over their own mailbox.

#### Usage

```remove-admin-on-all-mailboxes.ps1```

#### Example

```
PS > .\remove-admin-on-all-mailboxes.ps1
Enter the email address of an admin account on the tenant you would like connect to:
login: admin@contoso.com
Enter the email of the account that will lose access to all mailboxes.
admin email: admin@contoso.com
You are removing the ability for user admin@contoso.com access to all user mailboxes in the contoso.com (contoso.com) tenant. They will retain full control of their own mailbox. Type "y" to confirm
y
```

### remove-hold-on-all-mailboxes.ps1

#### Usage

```remove-hold-on-all-mailboxes.ps1```

#### Example

```
PS > .\remove-hold-on-all-mailboxes.ps1
Enter the email address of an admin account on the tenant you would like connect to:
login: admin@contoso.com

You are removing all holds on user inboxes in the contoso.com (contoso.com) tenant. Type "y" to confirm.
y
Done!
```
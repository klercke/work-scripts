# Exchange PowerShell Scripts

These scripts all operate within an Exchange Online session and therefore require the ExchangeOnlineManagement module.

## User Management

These scripts will iterate over every user in the tenant in one way or another to perform bulk operations.

### add-admin-on-all-mailboxes.ps1

This script will connect to a specified Exchange online session and give the specified user full access to all user mailboxes in that Exchange tenant.

#### Usage

```add-admin-on-all-mailboxes.ps1```

#### Example

```
PS> .\add-admin-on-all-mailboxes.ps1
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

This script will connect to a specified Exchange online session and remove full access to all user mailboxes in that Exchange tenant from a specified user, while retaining their full control over their own mailbox.

#### Usage

```remove-admin-on-all-mailboxes.ps1```

#### Example

```
PS> .\remove-admin-on-all-mailboxes.ps1
Enter the email address of an admin account on the tenant you would like connect to:
login: admin@contoso.com
Enter the email of the account that will lose access to all mailboxes.
admin email: admin@contoso.com
You are removing the ability for user admin@contoso.com access to all user mailboxes in the contoso.com (contoso.com) tenant. They will retain full control of their own mailbox. Type "y" to confirm
y
```

### remove-hold-on-all-mailboxes.ps1

This script will attempt to remove all holds on all mailboxes in the tenant.

#### Usage

```remove-hold-on-all-mailboxes.ps1```

#### Example

```
PS> .\remove-hold-on-all-mailboxes.ps1
Enter the email address of an admin account on the tenant you would like connect to:
login: admin@contoso.com

You are removing all holds on user inboxes in the contoso.com (contoso.com) tenant. Type "y" to confirm.
y
Done!
```

### enable-in-place-archive-on-all-mailboxes.ps1

This script will turn on the in-place archive on all mailboxes in the tenant.

#### Usage

```enable-in-place-archive-on-all-mailboxes.ps1```

#### Example

```
PS> .\enable-in-place-archive-on-all-mailboxes.ps1
Enter the email address of an admin account on the tenant you would like connect to:
login: admin@contoso.com
You are enabling the in-place archive for all user mailboxes in the contoso.com (contoso.com) tenant. Type "y" to confirm.
y

Name                      Alias           Database                       ProhibitSendQuota    ExternalDirectoryObjectId
----                      -----           --------                       -----------------    -------------------------
5v1r1c                    admin           NAMP222DG029-db084             99 GB (106,300,440,… 28c9da32-b5bb-4ddc-92db-838b78f49950
MiriamG                   MiriamG         NAMP222DG028-db282             99 GB (106,300,440,… cd2e5199-3bc1-4136-916d-1b6cd83321e4
IsaiahL                   IsaiahL         NAMP222DG019-db163             99 GB (106,300,440,… 5ee7e55f-b33a-4190-adb0-ed6a83995d3a
GradyA                    GradyA          NAMP222DG004-db075             99 GB (106,300,440,… fc6d2e84-e32d-43f4-a35e-b77352fee7c3
PattiF                    PattiF          NAMP222DG025-db146             99 GB (106,300,440,… 40abc036-6dcf-4a3a-8434-8732fdd9c218
AlexW                     AlexW           NAMP222DG025-db137             99 GB (106,300,440,… 5b8e5ce2-6755-4d0f-84fc-4f865972e880
JoniS                     JoniS           NAMP222DG027-db095             99 GB (106,300,440,… d8b69d7e-d236-4fdc-b67e-1062bf6ecbf2
AdeleV                    AdeleV          NAMP222DG033-db023             99 GB (106,300,440,… 4044044b-ed26-46ec-a5d1-1cefb7130c4b
LeeG                      LeeG            NAMP222DG015-db056             99 GB (106,300,440,… 9381b258-5d1c-4b40-a42c-6355d8bdb374
LynneR                    LynneR          NAMP222DG033-db076             99 GB (106,300,440,… b5c5f598-92ba-42fb-94d1-fe7852f0c08f
HenriettaM                HenriettaM      NAMP222DG028-db165             99 GB (106,300,440,… f1b258e7-86e1-4424-841b-e86a8c7ff3ed
PradeepG                  PradeepG        NAMP222DG034-db005             99 GB (106,300,440,… 051c6d81-60a1-43ea-97ba-90b0df8f0d7a
JohannaL                  JohannaL        NAMP222DG011-db140             99 GB (106,300,440,… 365ba134-ebbb-43e8-a593-5c881c0ce862
MeganB                    MeganB          NAMP222DG035-db240             99 GB (106,300,440,… 30b7ed0b-70fb-4188-a7c7-b41093f4eca5
NestorW                   NestorW         NAMP222DG033-db070             99 GB (106,300,440,… 2c54d651-8915-47a5-af1d-6fb27288a4b8
DiegoS                    DiegoS          NAMP222DG025-db078             99 GB (106,300,440,… 42f3dd19-217a-4e2d-86f0-eb4fefc62b6e
LidiaH                    LidiaH          NAMP222DG023-db115             99 GB (106,300,440,… fd9ba1e7-f3e5-4e26-aaf8-d40f7b5e4248
Done!
```

### disable-in-place-archive-on-all-mailboxes.ps1

This script will turn off the in-place archive on all mailboxes in the tenant.

#### Usage

```disable-in-place-archive-on-all-mailboxes.ps1```

#### Example

```
PS> .\disable-in-place-archive-on-all-mailboxes.ps1
Enter the email address of an admin account on the tenant you would like connect to:
login: admin@contoso.com
You are removing the in-place archive for all user mailboxes in the contoso.com (contoso.com) tenant. Type "y" to confirm.
y
Done!
```

### disable-litiagtion-hold-on-all-mailboxes.ps1

This script will disable litigation holds on all user mailboxes in the tenant.

### Usage

```disable-litiagtion-hold-on-all-mailboxes.ps1```

#### Example

```
PS> .\disable-litigation-hold-on-all-mailboxes.ps1
Enter the email address of an admin account on the tenant you would like connect to:
login: admin@contoso.com
You are disabling the litigation hold on all user mailboxes in the contoso.com (contoso.com) tenant. Type "y" to confirm.
y
Done!
```

### enable-litiagtion-hold-on-all-mailboxes.ps1

This script will enable a litigation hold with a specified duration on all user mailboxes in the tenant.

### Usage

```enable-litiagtion-hold-on-all-mailboxes.ps1```

#### Example

```
PS> .\enable-litigation-hold-on-all-mailboxes.ps1
Enter the email address of an admin account on the tenant you would like connect to:
login: admin@contoso.com
Enter the duration of the litigation hold in days. Enter -1 for unlimited.
hold duration: -1
You are enabling a litigation hold on all user mailboxes in the contoso.com (contoso.com) tenant. Type "y" to confirm.
y
Done!
```
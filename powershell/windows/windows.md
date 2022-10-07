# Windows PowerShell Scripts

These scripts are built to automate Windows administration tasks. If they require any PowerShell modules, it will be noted in that script's section below.

## Filesystem

These scripts will perform actions or collect information on the filesystem.

### directory-tree-to-csv.ps1

This script will iterate over every sub-directory of the given root directory and create a CSV containing the full path to each of them, one item per line.

#### Usage

```directory-tree-to-csv.ps1```

#### Example

```
PS> .\directory-tree-to-csv.ps1
Please enter the output filename:
filename [tree.csv]:
.\tree.csv already exists. Overwrite it? Type "y" to confirm.
y
Please enter the root search path:
path [.]:
Done!
```

### file-tree-to-csv.ps1

This script will iterate over every file and sub-directory (and those sub-directories' files) of the given root directory and create a CSV containing the full path to each of them, one item per line.

#### Usage

```file-tree-to-csv.ps1```

#### Example

```
PS> file-tree-to-csv.ps1
Please enter the output filename:
filename [tree.csv]:
.\tree.csv already exists. Overwrite it? Type "y" to confirm.
y
Please enter the root search path:
path [.]:
Done!
```
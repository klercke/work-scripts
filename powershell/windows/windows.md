# Windows PowerShell Scripts

These scripts are built to automate Windows administration tasks. If they require any PowerShell modules, it will be noted in that script's section below.

## Filesystem

These scripts will perform actions or collect information on the filesystem.

### directory-tree-to-csv.ps1

This script will iterate over every sub-directory of the given root directory and create a CSV containing the full path to each of them, one item per line.

#### Usage

```directory-tree-to-csv.ps1 [[-outfile] <string>] [[-rootpath] <string>] [<CommonParameters>]```

#### Options

 **Outfile**: The filename of the CSV that will be created. This can also be a path. If the file exists, it will be destroyed.

 **Rootpath**: The root directory to begin the search in. It will not be included in the CSV.

 **Verbose**: This will output each line to the console as it is added to the CSV


#### Example

```
PS> .\directory-tree-to-csv.ps1
.\tree.csv already exists. Overwrite it? Type "y" to confirm.
y
Done!
```

### file-tree-to-csv.ps1

This script will iterate over every file and sub-directory (and those sub-directories' files) of the given root directory and create a CSV containing the full path to each of them, one item per line.

#### Usage

```file-tree-to-csv.ps1 [[-outfile] <string>] [[-rootpath] <string>] [<CommonParameters>]```

#### Options

 **Outfile**: The filename of the CSV that will be created. This can also be a path. If the file exists, it will be destroyed.

 **Rootpath**: The root directory to begin the search in. It will not be included in the CSV.

 **Verbose**: This will output each line to the console as it is added to the CSV

#### Example

```
PS> .\file-tree-to-csv.ps1
.\tree.csv already exists. Overwrite it? Type "y" to confirm.
y
Done!
```
# Filesystem PowerShell Scripts

These scripts are built to assist with Filesystem tasks. If they require any PowerShell modules, it will be noted in that script's section below.

## One-liners

These scripts are too small/short/simple to get their own file and will only exist in this document:

### Get total size of directory

This script will iterate over every sub-directory of the given directory and print out the total size of the directory and all of its children in GB to two decimal points

#### Command

```$Path = Read-Host "Path to measure"; "Total size of $Path and all children: {0:N2} GB" -f ((Get-ChildItem –force $Path –Recurse -ErrorAction SilentlyContinue | Measure-Object Length -sum).sum / 1Gb)```

#### Example

```
PS> $Path = Read-Host "Path to measure"; "Total size of $Path and all children: {0:N2} GB" -f ((Get-ChildItem –force $Path –Recurse -ErrorAction SilentlyContinue | Measure-Object Length -sum).sum / 1Gb)
Path to measure: .
Total size of . and all children: 0.04 GB
```

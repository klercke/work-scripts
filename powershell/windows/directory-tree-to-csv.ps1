# File: directory-tree-to-csv.ps1
# Version: v1.1.0
# Author: Konnor Klercke

# Script options
[cmdletbinding()]
param(
    [Parameter(HelpMessage="Output filename")]
    [string]$outfile = ".\tree.csv",

    [Parameter(HelpMessage="Root search directory")]
    [string]$rootpath = "."
)

# Check if output file exists, if so confirm it is okay to delete and then do so
if (Test-Path $outfile -PathType Leaf) {
    Write-Host "$($outfile) already exists. Overwrite it? Type `"y`" to confirm."
    $confirm = Read-Host

    if ($confirm -eq "y") {
        Remove-Item $outfile
    }
    else {
        Exit
    }
}

# Search and build the CSV
Get-ChildItem -Directory -Recurse -Path $rootpath | ForEach-Object {(Write-Output $_.FullName >> $outfile); Write-Verbose "$($_)"}
Write-Host "Done!"
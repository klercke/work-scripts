# File: directory-tree-to-csv.ps1
# Version: v1.0.0
# Author: Konnor Klercke

# Get output filename, default to tree.csv
Write-Host "Please enter the output filename:"
$outfile = Read-Host -Prompt "filename [tree.csv]"
if ([string]::IsNullOrWhiteSpace($outfile)) {
    $outfile = '.\tree.csv'
}

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

# Get the root directory of the tree
Write-Host "Please enter the root search path:"
$rootpath = Read-Host -Prompt "path [.]"
if ([string]::IsNullOrWhiteSpace($rootpath)) {
    $rootpath = '.'
}

# Search and build the CSV
Get-ChildItem -Directory -Recurse -Path $rootpath | ForEach-Object {Write-Output $_.FullName >> $outfile}
Write-Host "Done!"
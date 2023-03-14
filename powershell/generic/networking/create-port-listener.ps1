# File: create-port-listener.ps1
# Version: v1.0.0
# Author: Konnor Klercke
# https://stackoverflow.com/questions/13129060/opening-up-a-port-with-powershell

# Script options
[cmdletbinding()]
param(
    [Parameter(HelpMessage="Listen port", Mandatory=$true)]
    [string]$Port,

    [Parameter(HelpMessage="Loop enabled")]
    [string]$Loop = "false"
)

# Set up variables
$LoopEnabled = [System.Convert]::ToBoolean($Loop)
$PortNo = [int]($Port)
$Repeat = $true

# Get interface IP
# https://stackoverflow.com/questions/27277701/powershell-get-ipv4-address-into-a-variable
$IP = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress

# Open the port
$Listener = [System.Net.Sockets.TcpListener]$PortNo;
try {
    $Listener.Start();
}
catch {
    Write-Host "Failed to start listener. Please make sure port $port is not in use on your system."
    Exit
}

# Main loop to listen for connections
$Connections = 0
Write-Host "Listener started. Test connection with `"Test-NetConnection -ComputerName $ip -Port $port`""
while ($Repeat){
    # Accept the connection then close it so another can start
    $client = $Listener.AcceptTcpClient();
    Write-Host "Client connection accepted on port $port";
    $client.Close();

    # Count the number of total connetions
    $Connections = $Connections + 1

    # Continue loop if necessary
    if (-not $LoopEnabled) {
        $Repeat = $false
    }
}

# Shut down
Write-Host "Terminating listener. Connections received: $Connections"
$Listener.Stop();

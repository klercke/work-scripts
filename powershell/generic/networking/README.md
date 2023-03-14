# Networking PowerShell Scripts

These scripts are built to assist with Networking tasks. If they require any PowerShell modules, it will be noted in that script's section below.

## Troubleshooting

These scripts will help collect data for troubleshooting

### create-port-listener.ps1

This script will create a port listener on a specified port and waits for a connection to be opened on that port, then exits. Optionally, stays open until the window is closed.

#### Usage

```create-port-listener.ps1 [-Port] <string> [[-Loop] <string>] [<CommonParameters>]```

#### Options

 **Port**: The port to open the listener on. This must be an unused port on the local system.

 **Loop**: Whether or not the script should loop infinitely. Note: There is no way to exit this loop other than closing the window running the script. Use with caution.

#### Example

```
PS> .\create-port-listener.ps1 9999
Listener started. Test connection with "Test-NetConnection -ComputerName 192.168.1.2 -Port 9999"
Client connection accepted on port 9999
Terminating listener. Connections received: 1
```
# Gets the current network configuration.
# Account used must have either local admin or remote admin rights on system.
# Can sometimes fail with "RPC server not available" error depending on system configuration or if the computer is offline.

# Example querying all software.
$comp = Read-Host "Enter Computer Name"
# Check if computer is online (try up to three times).
If((Test-Connection -ComputerName $comp -Count 1 -Quiet) -Or (Test-Connection -ComputerName $comp -Count 1 -Quiet) -Or (Test-Connection -ComputerName $comp -Count 1 -Quiet)) {
	Write-Host "[$comp] appears to be online, querying..."
} else {
	Write-Warning "[$comp] did not respond to any ping attempts, querying anyway..."
}
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $comp | Select DHCPEnabled, IPAddress, DefaultIPGateway, DNSDomain, DNSServerSearchOrder, MACAddress, ServiceName, Description, Index
Read-Host "Press enter to exit" | Out-Null

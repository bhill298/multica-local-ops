#Requires -Version 7.3
param([Parameter(Mandatory)][ipaddress]$Address)
$ErrorActionPreference='Stop'
if ($Address.IPAddressToString -eq '127.0.0.1') { return }
$bytes=$Address.GetAddressBytes()
if ($bytes.Length -ne 4 -or !($bytes[0] -eq 10 -or ($bytes[0] -eq 172 -and $bytes[1] -in (16..31)) -or ($bytes[0] -eq 192 -and $bytes[1] -eq 168))) {
    throw 'Use a private LAN IPv4 address, or 127.0.0.1 to turn LAN access off.'
}
$ip=@(Get-NetIPAddress -IPAddress $Address.IPAddressToString -AddressFamily IPv4 -AddressState Preferred -ErrorAction SilentlyContinue)
if ($ip.Count -ne 1 -or $ip[0].PrefixLength -lt 1) { throw "The address $Address must be assigned to one connected Windows interface." }
$profile=Get-NetConnectionProfile -InterfaceIndex $ip[0].InterfaceIndex -ErrorAction SilentlyContinue
if ($profile.NetworkCategory -ne 'Private') {
    throw "The interface for $Address must use the Private Windows network profile. Check Network & internet properties for the trusted LAN."
}
[pscustomobject]@{Binding="$Address/$($ip[0].PrefixLength)";Interface=$ip[0].InterfaceAlias}

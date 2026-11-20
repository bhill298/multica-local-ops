#Requires -RunAsAdministrator
[CmdletBinding()]
param([Parameter(Mandatory)][guid]$VMId,[switch]$PolicyOnly)
$ErrorActionPreference='Stop'
$vm=Get-VM -Id $VMId
$root=$PSScriptRoot
$policy=Get-Content -LiteralPath "$root/network.json" -Raw | ConvertFrom-Json
$nic=Get-VMNetworkAdapter -VM $vm
$alias='vEthernet (Default Switch)'
$deadline=[datetime]::UtcNow.AddMinutes(3)
do {
    $gw=(Get-NetIPAddress -InterfaceAlias $alias -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1).IPAddress
    if ($gw) { break }
    Start-Sleep 2
} while ([datetime]::UtcNow -lt $deadline)
if (!$gw) { throw 'Default Switch is not ready.' }
$deny=@('10.0.0.0/8','172.16.0.0/12','192.168.0.0/16','169.254.0.0/16','100.64.0.0/10','224.0.0.0/4','::/0')
$deny+=@(Get-NetRoute -AddressFamily IPv4 | Where-Object { $_.DestinationPrefix -ne '0.0.0.0/0' -and $_.NextHop -eq '0.0.0.0' } | Select-Object -ExpandProperty DestinationPrefix)
$deny=@(($deny + @($policy.additionalBlockedNetworks)) | Where-Object { $_ } | Sort-Object -Unique)
$stamp=$gw+' '+($deny -join ' ')
$last=Get-Content "$root/applied-network.txt" -ErrorAction SilentlyContinue
if ($stamp -ne $last -or !$nic.SwitchName) {
    if ($nic.SwitchName) { Disconnect-VMNetworkAdapter -VMNetworkAdapter $nic }
    Get-VMNetworkAdapterExtendedAcl -VMNetworkAdapter $nic | Remove-VMNetworkAdapterExtendedAcl
    $weight=1
    foreach ($network in $deny) {
        Add-VMNetworkAdapterExtendedAcl -VMNetworkAdapter $nic -Direction Outbound -Action Deny -RemoteIPAddress $network -Weight $weight
        $weight++
    }
    foreach ($proto in 'UDP','TCP') {
        Add-VMNetworkAdapterExtendedAcl -VMNetworkAdapter $nic -Direction Outbound -Action Allow -RemoteIPAddress $gw -Protocol $proto -RemotePort 53 -Weight (64000+[int]($proto -eq 'TCP'))
    }
    foreach ($server in $gw,'255.255.255.255') {
        Add-VMNetworkAdapterExtendedAcl -VMNetworkAdapter $nic -Direction Outbound -Action Allow -Protocol UDP -LocalPort 68 -RemotePort 67 -RemoteIPAddress $server -Weight (64100+[int]($server -eq $gw))
    }
    Add-VMNetworkAdapterExtendedAcl -VMNetworkAdapter $nic -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22 -RemoteIPAddress $gw -Stateful $true -Weight 64200
    Add-VMNetworkAdapterExtendedAcl -VMNetworkAdapter $nic -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -RemoteIPAddress $gw -Stateful $true -Weight 64201
    Add-VMNetworkAdapterExtendedAcl -VMNetworkAdapter $nic -Direction Inbound -Action Deny -Protocol TCP -LocalPort 445 -Weight 63900
    Connect-VMNetworkAdapter -VMNetworkAdapter $nic -SwitchName 'Default Switch'
    Set-Content "$root/applied-network.txt" $stamp
}
if ($PolicyOnly) { return }
if ((Get-VM -Id $VMId).State -eq 'Off') { Start-VM -VM $vm }
$deadline=[datetime]::UtcNow.AddMinutes(8)
do {
    $nic=Get-VMNetworkAdapter -VM $vm
    $ip=$nic.IPAddresses | Where-Object { $_ -match '^\d+\.' } | Select-Object -First 1
    if (!$ip) {
        $ip=(Get-NetNeighbor -InterfaceAlias $alias -AddressFamily IPv4 |
            Where-Object { ($_.LinkLayerAddress -replace '-','') -eq $nic.MacAddress } | Select-Object -First 1).IPAddress
    }
    if ($ip) { break }
    Start-Sleep 3
} while ([datetime]::UtcNow -lt $deadline)
if (!$ip) { throw 'Guest address discovery timed out.' }
$tmp="$root/vm-$PID.tmp"
@{id=$VMId.ToString();phase='installed';address=$ip} | ConvertTo-Json | Set-Content $tmp
[IO.File]::Replace($tmp,"$root/vm.json","$root/vm.previous.json")

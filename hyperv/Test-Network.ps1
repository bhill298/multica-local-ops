#Requires -Version 7.3
#Requires -RunAsAdministrator
[CmdletBinding()]
param([string]$Name='Multica-Ubuntu',[string]$Directory="$env:LOCALAPPDATA/MulticaVM/media")
$ErrorActionPreference='Stop'
if ($Name -notmatch '^[A-Za-z0-9-]{1,50}$') { throw 'Invalid VM name.' }
$root=Join-Path $env:ProgramFiles "MulticaVM/$Name"
$state=Get-Content "$root/vm.json" -Raw | ConvertFrom-Json
$vm=Get-VM -Id $state.id
$nic=Get-VMNetworkAdapter -VM $vm
$alias='vEthernet (Default Switch)'
$gateway=(Get-NetIPAddress -InterfaceAlias $alias -AddressFamily IPv4 | Select-Object -First 1).IPAddress
$keyRoot=Split-Path ([IO.Path]::GetFullPath($Directory))
$opts=@('-o','BatchMode=yes','-o','ConnectTimeout=5','-o',"HostKeyAlias=$Name",'-o','StrictHostKeyChecking=yes','-o',"UserKnownHostsFile=$keyRoot/known_hosts",'-i',"$keyRoot/keys/operator","multicaops@$($state.address)")
function Test-WorkerConnection([ipaddress]$Address,[int]$Port) {
    $ip=$Address.IPAddressToString
    $response=ssh @opts "sudo docker exec multica-vm-codex-1 python3 -c 'import socket;s=socket.socket();s.settimeout(2);print(s.connect_ex((`"$ip`",$Port)))'"
    if ($LASTEXITCODE -ne 0 -or "$response" -notmatch '^\d+$') { throw 'Worker probe failed to execute.' }
    return ([int]$response -eq 0)
}
$addresses=@($gateway)
$lan=Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } | Select-Object -First 1
if ($lan) { $addresses+=@($lan.IPv4Address.IPAddress) }
$results=foreach ($ip in ($addresses | Sort-Object -Unique)) {
    $listener=[Net.Sockets.TcpListener]::new([ipaddress]$ip,0)
    $listener.Start()
    $port=$listener.LocalEndpoint.Port
    $rule=$null
    $acl=$null
    try {
        $rule=New-NetFirewallRule -DisplayName "Multica test listener $($vm.Id)" -Profile Any -Action Allow -Direction Inbound -Protocol TCP -LocalAddress $ip -LocalPort $port -RemoteAddress $state.address
        if (Test-WorkerConnection $ip $port) { throw "Worker reached host listener at $ip before positive control." }
        $acl=Add-VMNetworkAdapterExtendedAcl -VMNetworkAdapter $nic -Direction Outbound -Action Allow -Protocol TCP -RemoteIPAddress $ip -RemotePort $port -Weight 65000 -Passthru
        if (!(Test-WorkerConnection $ip $port)) { throw "Positive control did not reach $ip. Isolation result is inconclusive." }
        Remove-VMNetworkAdapterExtendedAcl -InputObject $acl
        $acl=$null
        if (Test-WorkerConnection $ip $port) { throw "Worker reached $ip after restoring the policy." }
        [ordered]@{destination=$ip;blockedBefore=$true;allowedControl=$true;blockedAfter=$true}
    } finally {
        if ($acl) { Remove-VMNetworkAdapterExtendedAcl -InputObject $acl }
        if ($rule) { Remove-NetFirewallRule -Name $rule.Name }
        $listener.Stop()
    }
}
@($results) | ConvertTo-Json | Set-Content "$root/isolation-result.json"

#Requires -RunAsAdministrator
[CmdletBinding()]
param([Parameter(Mandatory)][guid]$VMId,[switch]$WaitForAddress)
$ErrorActionPreference='Stop'
$vm=Get-VM -Id $VMId
if ($vm.State -ne 'Running') { return }
$path=Join-Path $PSScriptRoot vm.json
$state=Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
if ($state.id -ne "$VMId" -or $state.phase -ne 'installed') { throw 'Guest identity or installation phase mismatch.' }
$limit=[datetime]::UtcNow.AddMinutes(8)
do {
    $nic=Get-VMNetworkAdapter -VM $vm
    $ip=$nic.IPAddresses | Where-Object { $_ -match '^\d+\.' } | Select-Object -First 1
    if (!$ip) {
        $ip=(Get-NetNeighbor -InterfaceAlias 'vEthernet (Default Switch)' -AddressFamily IPv4 |
            Where-Object { ($_.LinkLayerAddress -replace '-','') -eq $nic.MacAddress -and $_.State -in 'Permanent','Reachable' } |
            Select-Object -First 1).IPAddress
    }
    if ($ip -or !$WaitForAddress) { break }
    Start-Sleep 3
} while ([datetime]::UtcNow -lt $limit)
if (!$ip) {
    if ($WaitForAddress) { throw 'Guest address discovery timed out.' }
    return
}
$changed=$state.address -ne $ip
if ($changed) {
    $tmp=Join-Path $PSScriptRoot "vm-$PID.tmp"
    @{id="$VMId";phase='installed';address=$ip} | ConvertTo-Json | Set-Content $tmp
    [IO.File]::Replace($tmp,$path,(Join-Path $PSScriptRoot vm.previous.json))
}
# Interactive tasks have their own logon triggers. After a guest-only reboot
# a disconnected SSH relay may already have exited with Windows still signed in.
if (Get-Process explorer -ErrorAction SilentlyContinue) {
    $relay=Get-ScheduledTask -TaskName "$($vm.Name) dashboard relay" -ErrorAction SilentlyContinue
    if ($relay -and $relay.State -eq 'Ready') { Start-ScheduledTask -InputObject $relay }
    $drive=Get-ScheduledTask -TaskName "$($vm.Name) project drive" -ErrorAction SilentlyContinue
    if ($drive -and $drive.State -eq 'Ready' -and ($changed -or (Get-ScheduledTaskInfo -InputObject $drive).LastTaskResult -ne 0)) {
        Start-ScheduledTask -InputObject $drive
    }
}

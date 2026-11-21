#Requires -Version 7.3
#Requires -RunAsAdministrator
param([ValidatePattern('^[A-Za-z0-9-]{1,50}$')][string]$Name,[string]$Directory,
      [ValidatePattern('^[a-z0-9][a-z0-9-]{0,49}$')][string]$Prefix,[ValidateRange(1,65535)][int]$WebPort,[ipaddress]$LanAddress='127.0.0.1')
$ErrorActionPreference='Stop'
$root=Join-Path $env:ProgramFiles "MulticaVM/$Name"
$state=Get-Content "$root/vm.json" -Raw | ConvertFrom-Json
$vm=Get-VM -Id $state.id
if ($vm.Name -ne $Name -or $state.phase -ne 'installed') {throw 'This VM is not owned by this install.'}
$directory=[IO.Path]::GetFullPath($Directory)
$dir=Join-Path $root portal
$null=New-Item -ItemType Directory -Force -Path $dir,"$dir/hyperv"
if (Test-Path "$dir/install.json") {
    $old=Get-Content "$dir/install.json" -Raw | ConvertFrom-Json
    if ($old.id -ne $state.id -or $old.directory -ne $directory -or $old.prefix -ne $Prefix) {throw 'Another operator profile or hostname is already registered.'}
}
. "$PSScriptRoot/Portal-Hosts.ps1"
Set-PortalHosts -Id $vm.Id -Prefix $Prefix
$lan=& "$PSScriptRoot/Get-PortalLanBinding.ps1" -Address $LanAddress
$rule="MulticaPortal-LAN-$($vm.Id)"
Get-NetFirewallRule -Name $rule -ErrorAction SilentlyContinue | Remove-NetFirewallRule
if ($lan) {
    $exe=[IO.Path]::GetFullPath((Join-Path (Split-Path $directory) 'portal/multica-portal.exe'))
    New-NetFirewallRule -Name $rule -DisplayName "$Name LAN portal" -Direction Inbound -Action Allow -Profile Private -Protocol TCP -LocalAddress $LanAddress.IPAddressToString -LocalPort $WebPort -RemoteAddress LocalSubnet -InterfaceAlias $lan.Interface -Program $exe -EdgeTraversalPolicy Block | Out-Null
}
@{name=$Name;id=$state.id;prefix=$Prefix;webPort=$WebPort;directory=$directory;lanAddress=$LanAddress.IPAddressToString} | ConvertTo-Json | Set-Content "$dir/install.json"
Copy-Item "$PSScriptRoot/Portal-Action.ps1","$PSScriptRoot/Dashboard-Health.ps1","$PSScriptRoot/portal-status.py","$PSScriptRoot/Portal-Hosts.ps1","$PSScriptRoot/../update-vm.ps1" $dir -Force
Copy-Item "$PSScriptRoot/update-release.py","$PSScriptRoot/Test-UpstreamSql.ps1" "$dir/hyperv/" -Force
Copy-Item "$PSScriptRoot/Sync-GuestAddress.ps1" $root -Force
& "$root/Sync-GuestAddress.ps1" -VMId $vm.Id

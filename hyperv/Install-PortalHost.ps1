#Requires -Version 7.3
#Requires -RunAsAdministrator
param([ValidatePattern('^[A-Za-z0-9-]{1,50}$')][string]$Name,[string]$Directory,
      [ValidatePattern('^[a-z0-9][a-z0-9-]{0,49}$')][string]$Prefix,[int]$WebPort)
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
@{name=$Name;id=$state.id;prefix=$Prefix;webPort=$WebPort;directory=$directory} | ConvertTo-Json | Set-Content "$dir/install.json"
Copy-Item "$PSScriptRoot/Portal-Action.ps1","$PSScriptRoot/portal-status.py","$PSScriptRoot/Portal-Hosts.ps1","$PSScriptRoot/../update-vm.ps1" $dir -Force
Copy-Item "$PSScriptRoot/update-release.py" "$dir/hyperv/" -Force
Copy-Item "$PSScriptRoot/Sync-GuestAddress.ps1" $root -Force
& "$root/Sync-GuestAddress.ps1" -VMId $vm.Id

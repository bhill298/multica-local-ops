#Requires -RunAsAdministrator
#Requires -Version 7.3
param([Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9-]{1,50}$')][string]$Name,
    [Parameter(Mandatory)][guid]$VMId,[Parameter(Mandatory)][string]$Directory,[switch]$KeepDisk)
$ErrorActionPreference='Stop'
$parent=[IO.Path]::GetFullPath((Join-Path $env:ProgramFiles MulticaVM))
$root=[IO.Path]::GetFullPath((Join-Path $parent $Name))
if ((Split-Path $root) -ne $parent -or !(Test-Path -LiteralPath $root)) {throw 'Missing protected installation folder.'}
foreach ($item in @((Get-Item $parent),(Get-Item $root))+@(Get-ChildItem -LiteralPath $root -Force -Recurse)) {
    if ($item.Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)) {throw "Refusing linked path: $($item.FullName)"}
}
$state=Get-Content "$root/vm.json" -Raw | ConvertFrom-Json
if ($VMId -ne $state.id){throw 'VM identity changed.'}
$portal=if (Test-Path "$root/portal/install.json") { Get-Content "$root/portal/install.json" -Raw | ConvertFrom-Json }
if ($portal -and ($portal.id -ne $state.id -or $portal.directory -ne [IO.Path]::GetFullPath($Directory))) { throw 'Wrong portal owner or operator directory.' }
$diskHome=[IO.Path]::GetFullPath((Get-VMHost).VirtualHardDiskPath).TrimEnd('\')
$disk=[IO.Path]::GetFullPath((Join-Path $diskHome "$Name-system.vhdx"))
if ((Split-Path $disk) -ne $diskHome) {throw 'Unexpected disk path.'}
$receipt="$root/uninstall.json"
$vm=Get-VM -Id $VMId -ErrorAction SilentlyContinue
if ($vm) {
    if ($vm.Name -ne $Name) {throw 'Wrong VM name.'}
    $drives=@(Get-VMHardDiskDrive -VM $vm)
    if ($drives.Count -ne 1) {throw 'Additional or missing VM disks. Review the disk layout before uninstalling.'}
    $path=$drives[0].Path
    do {
        $vhd=Get-VHD -Path $path
        if ((Split-Path ([IO.Path]::GetFullPath($path))) -ne $diskHome) {throw 'A disk was moved outside the managed disk folder.'}
        if ((Get-Item -LiteralPath $path).Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)) {throw 'Refusing a linked disk.'}
        $path=$vhd.ParentPath
    } while ($path)
    if ([IO.Path]::GetFullPath($vhd.Path) -ne $disk){throw 'Unexpected base disk. Refusing removal.'}
} elseif (!(Test-Path $receipt) -or (Get-VM -Name $Name -ErrorAction SilentlyContinue)) {throw 'VM missing or name reassigned. Inspect Hyper-V.'}
if (Test-Path $receipt) {
    $previous=Get-Content $receipt -Raw | ConvertFrom-Json
    if ($previous.id -ne "$VMId" -or $previous.disk -ne $disk -or $previous.keep -ne [bool]$KeepDisk) {throw 'Resume with the same disk choice and VM identity.'}
}
$lock=[IO.File]::Open("$root/update.lock",'OpenOrCreate','ReadWrite','None')
$op=$null
try {
    if ($portal){$op=[IO.File]::Open("$root/portal/operation.lock",'OpenOrCreate','ReadWrite','None')}
    @{id="$VMId";disk=$disk;keep=[bool]$KeepDisk} | ConvertTo-Json | Set-Content $receipt
    if ($portal) { . "$PSScriptRoot/Portal-Hosts.ps1"; Set-PortalHosts -Id $VMId -Prefix $portal.prefix -Remove }
    if ($portal) { Get-NetFirewallRule -Name "MulticaPortal-LAN-$VMId" -ErrorAction SilentlyContinue | Remove-NetFirewallRule }
    foreach ($suffix in 'unattended boot','address refresh','managed checkpoints','project drive','dashboard relay','management portal') {
        $task=Get-ScheduledTask -TaskPath '\' -TaskName "$Name $suffix" -ErrorAction SilentlyContinue
        if ($task) { Disable-ScheduledTask -InputObject $task | Out-Null; Stop-ScheduledTask -InputObject $task; Unregister-ScheduledTask -InputObject $task -Confirm:$false }
    }
    if ($vm) {
        if ($vm.State -ne 'Off') {Stop-VM -VM $vm -Confirm:$false -ErrorAction Stop}
        Get-VMSnapshot -VM $vm | Remove-VMSnapshot -Confirm:$false
        $end=(Get-Date).AddMinutes(30)
        while ([IO.Path]::GetFullPath((Get-VMHardDiskDrive -VM $vm).Path) -ne $disk) {
            if ((Get-Date) -gt $end){throw 'Checkpoint merge still running. Retry uninstall after it completes.'}
            Start-Sleep 2
        }
        Remove-VM -VM $vm -Force
    }
    if (!$KeepDisk -and (Test-Path -LiteralPath $disk)) {Remove-Item -LiteralPath $disk -Force}
} finally {if ($op){$op.Dispose()};$lock.Dispose()}
Remove-Item -LiteralPath $root -Recurse -Force

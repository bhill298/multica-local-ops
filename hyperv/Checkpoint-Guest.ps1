#Requires -RunAsAdministrator
[CmdletBinding()]
param([Parameter(Mandatory)][guid]$VMId,[ValidateRange(1,52)][int]$Keep=4,
      [ValidateRange(5,1024)][int]$MinFreeGiB=20)
$ErrorActionPreference='Stop'
$vm = Get-VM -Id $VMId
if ($vm.State -ne 'Running') { throw 'Guest must be running for a production checkpoint.' }
if ($vm.CheckpointType -ne 'ProductionOnly') { throw 'ProductionOnly checkpoint mode is required.' }
foreach ($drive in (Get-VMHardDiskDrive $vm)) {
    if ([IO.DriveInfo]::new([IO.Path]::GetPathRoot($drive.Path)).AvailableFreeSpace -lt $MinFreeGiB * 1GB) { throw 'Insufficient space on checkpoint storage.' }
}
$prefix = "MulticaManaged-$VMId-"
$name = $prefix + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffffffZ')
$new = Checkpoint-VM -VM $vm -SnapshotName $name -Passthru -ErrorAction Stop
if (!$new.Id) { throw 'Hyper-V did not return a checkpoint ID.' }
Get-VMSnapshot -VM $vm | Where-Object { $_.Name.StartsWith($prefix) } |
    Sort-Object CreationTime -Descending | Select-Object -Skip $Keep |
    ForEach-Object { Remove-VMSnapshot -VMSnapshot $_ -ErrorAction Stop }

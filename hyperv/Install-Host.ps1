#Requires -Version 7.2
#Requires -RunAsAdministrator
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Media,
    [string]$Name='Multica-Ubuntu', [int]$Processors, [int]$MaximumGiB,
    [ValidateRange(40,2048)][int]$DiskGiB=128,
    [ValidateRange(1,52)][int]$Keep=4, [DayOfWeek]$CheckpointDay='Sunday',
    [datetime]$CheckpointAt='03:00', [string[]]$AdditionalBlockedNetworks=@())
$ErrorActionPreference='Stop'
if ($Name -notmatch '^[A-Za-z0-9-]{1,50}$') { throw 'Use an alphanumeric VM name with optional hyphens.' }
if (!(Get-Command Get-VM -ErrorAction SilentlyContinue) -or (Get-Service vmms).Status -ne 'Running') { throw 'Enable Hyper-V and its PowerShell management tools, enable virtualization in firmware, then reboot.' }
$cs=Get-CimInstance Win32_ComputerSystem
if (!$cs.HypervisorPresent -or $cs.TotalPhysicalMemory -lt 15GB) { throw 'A running hypervisor and a host with approximately 16 GiB RAM or more are required.' }
$available=(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory * 1KB
$startup=4GB
if (!$Processors) { $Processors=[Math]::Max(2,[Math]::Min(8,[int]($cs.NumberOfLogicalProcessors/2))) }
if (!$MaximumGiB) { $MaximumGiB=[Math]::Min(64,[Math]::Floor($cs.TotalPhysicalMemory/1GB * 0.65)) }
if ($MaximumGiB -lt 4 -or $MaximumGiB * 1GB -ge $cs.TotalPhysicalMemory -or $Processors -lt 1 -or $Processors -gt $cs.NumberOfLogicalProcessors) { throw 'Invalid CPU or memory settings for this host.' }
$switch=Get-VMSwitch -Name 'Default Switch'
$root=Join-Path $env:ProgramFiles "MulticaVM/$Name"
$null=New-Item -ItemType Directory -Force -Path $root
Start-Transcript -Path "$root/provision.log" -Append | Out-Null
$stateFile=Join-Path $root vm.json
$vm=Get-VM -Name $Name -ErrorAction SilentlyContinue
if ($vm -and (!(Test-Path $stateFile) -or (Get-Content $stateFile -Raw | ConvertFrom-Json).id -ne $vm.Id.ToString())) { throw 'A VM already uses this name and is not owned by this installer.' }
$hostConfig=Get-VMHost
$vhd=Join-Path $hostConfig.VirtualHardDiskPath "$Name-system.vhdx"
if (!$vm) {
    if (Test-Path $stateFile) { throw 'State refers to a missing VM. Review the VM inventory before recreating it.' }
    if (Test-Path $vhd) { throw "An existing disk is in the way: $vhd" }
    if ($available -lt 5GB) { throw 'Free at least 5 GiB of host RAM for installation.' }
    if ([IO.DriveInfo]::new([IO.Path]::GetPathRoot($vhd)).AvailableFreeSpace -lt 40GB) { throw 'Free at least 40 GiB on the Hyper-V virtual disk drive.' }
    $null=New-Item -ItemType Directory -Force -Path $root
    $vm=New-VM -Name $Name -Generation 2 -MemoryStartupBytes $startup -NewVHDPath $vhd -NewVHDSizeBytes ($DiskGiB*1GB)
    @{id=$vm.Id.ToString();phase='created'} | ConvertTo-Json | Set-Content $stateFile
}
$state=Get-Content $stateFile -Raw | ConvertFrom-Json
Copy-Item "$PSScriptRoot/Start-Guest.ps1" "$root/Start-Guest.ps1" -Force
Copy-Item "$PSScriptRoot/Sync-GuestAddress.ps1" "$root/Sync-GuestAddress.ps1" -Force
if (!(Test-Path "$root/network.json") -or $PSBoundParameters.ContainsKey('AdditionalBlockedNetworks')) {
    @{additionalBlockedNetworks=@($AdditionalBlockedNetworks)} | ConvertTo-Json | Set-Content "$root/network.json"
}
if ($state.phase -eq 'created') {
    if ($vm.State -ne 'Off') { throw 'Unexpected running VM before network policy installation.' }
    $nic=Get-VMNetworkAdapter -VM $vm
    if (!$nic) { $nic=Add-VMNetworkAdapter -VM $vm -Passthru }
    & "$root/Start-Guest.ps1" -VMId $vm.Id -PolicyOnly
    Set-VMProcessor -VM $vm -Count $Processors
    Set-VMMemory -VM $vm -DynamicMemoryEnabled $true -MinimumBytes 2GB -StartupBytes $startup -MaximumBytes ($MaximumGiB*1GB)
    Set-VM -VM $vm -AutomaticCheckpointsEnabled $false -CheckpointType ProductionOnly -AutomaticStartAction Nothing -AutomaticStopAction ShutDown
    Set-VMFirmware -VM $vm -EnableSecureBoot On -SecureBootTemplate MicrosoftUEFICertificateAuthority
    $dvd=Get-VMDvdDrive -VM $vm
    if (!$dvd) { $dvd=Add-VMDvdDrive -VM $vm -Path $Media -Passthru } else { Set-VMDvdDrive -VMDvdDrive $dvd -Path $Media }
    Set-VMFirmware -VM $vm -FirstBootDevice $dvd
    $state.phase='installing'; $state | ConvertTo-Json | Set-Content $stateFile
    Start-VM -VM $vm
}
if ($state.phase -eq 'installing') {
    $deadline=[datetime]::UtcNow.AddMinutes(60)
    while ((Get-VM -Id $vm.Id).State -ne 'Off') {
        if ([datetime]::UtcNow -gt $deadline) { throw 'Installation has not powered off. Inspect the guest in Hyper-V Manager.' }
        Start-Sleep 10
    }
    Set-VMDvdDrive -VMName $Name -Path $null
    Set-VMFirmware -VM $vm -FirstBootDevice (Get-VMHardDiskDrive -VM $vm)
    $state.phase='installed'; $state | ConvertTo-Json | Set-Content $stateFile
}
Set-VM -VM $vm -AutomaticStartAction Nothing -AutomaticStopAction ShutDown
Copy-Item "$PSScriptRoot/Checkpoint-Guest.ps1" "$root/Checkpoint-Guest.ps1" -Force
$action=New-ScheduledTaskAction -Execute "$env:SystemRoot/System32/WindowsPowerShell/v1.0/powershell.exe" -Argument ('-NoProfile -NonInteractive -WindowStyle Hidden -File "{0}" -VMId {1} -Keep {2}' -f "$root/Checkpoint-Guest.ps1",$vm.Id,$Keep)
$trigger=New-ScheduledTaskTrigger -Weekly -DaysOfWeek $CheckpointDay -At $CheckpointAt
Register-ScheduledTask -TaskName "$Name managed checkpoints" -Action $action -Trigger $trigger -User SYSTEM -RunLevel Highest -Settings (New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew) -Force | Out-Null
$bootAction=New-ScheduledTaskAction -Execute "$env:SystemRoot/System32/WindowsPowerShell/v1.0/powershell.exe" -Argument ('-NoProfile -NonInteractive -WindowStyle Hidden -File "{0}" -VMId {1}' -f "$root/Start-Guest.ps1",$vm.Id)
Register-ScheduledTask -TaskName "$Name unattended boot" -Action $bootAction -Trigger (New-ScheduledTaskTrigger -AtStartup) -User SYSTEM -RunLevel Highest -Settings (New-ScheduledTaskSettingsSet -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1) -StartWhenAvailable -MultipleInstances IgnoreNew) -Force | Out-Null
& "$root/Start-Guest.ps1" -VMId $vm.Id
$syncAction=New-ScheduledTaskAction -Execute "$env:SystemRoot/System32/WindowsPowerShell/v1.0/powershell.exe" -Argument ('-NoProfile -NonInteractive -WindowStyle Hidden -File "{0}" -VMId {1}' -f "$root/Sync-GuestAddress.ps1",$vm.Id)
$syncTrigger=New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(10) -RepetitionInterval (New-TimeSpan -Minutes 2)
Register-ScheduledTask -TaskName "$Name address refresh" -Action $syncAction -Trigger $syncTrigger -User SYSTEM -RunLevel Highest -Settings (New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries) -Force | Out-Null

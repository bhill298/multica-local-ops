#Requires -Version 7.3
#Requires -RunAsAdministrator
# Creates two empty, powered-off VMs. No production VM, keys or data are used.
$ErrorActionPreference='Stop'
$diskHome=[IO.Path]::GetFullPath((Get-VMHost).VirtualHardDiskPath)
foreach ($keep in $false,$true) {
    $name='Multica-UninstallTest-'+[guid]::NewGuid().ToString('N').Substring(0,10)
    $profileDir=Join-Path ([IO.Path]::GetTempPath()) $name
    $root=Join-Path "$env:ProgramFiles/MulticaVM" $name
    $disk=Join-Path $diskHome "$name-system.vhdx"
    if ((Get-VM -Name $name -ErrorAction SilentlyContinue) -or (Test-Path $disk) -or (Test-Path $root) -or (Test-Path $profileDir)) {throw 'Test resource already exists.'}
    $vm=New-VM -Name $name -Generation 2 -NewVHDPath $disk -NewVHDSizeBytes 256MB -MemoryStartupBytes 512MB
    $media=Join-Path $profileDir media
    $null=New-Item -ItemType Directory -Path "$root/portal",$media,"$profileDir/keys"
    @{id=$vm.Id.ToString();phase='installed'} | ConvertTo-Json | Set-Content "$root/vm.json"
    @{id=$vm.Id.ToString();name=$name;prefix=$name.ToLowerInvariant();directory=$media} | ConvertTo-Json | Set-Content "$root/portal/install.json"
    Set-Content "$profileDir/vm-name.txt" $name
    Set-Content "$profileDir/keys/operator" 'disposable fixture'
    Set-Content "$media/keep-user-file.txt" 'operator file'
    . "$PSScriptRoot/Portal-Hosts.ps1"
    Set-PortalHosts -Id $vm.Id -Prefix $name.ToLowerInvariant()
    if ($keep) {
        $source=Join-Path $profileDir source
        $null=New-Item -ItemType Directory -Path $source
        $repo=Split-Path $PSScriptRoot
        Copy-Item "$repo/hyperv","$repo/cmd","$repo/go.mod","$repo/update-vm.ps1" $source -Recurse
        $probes=@(1..3 | ForEach-Object {
            $listener=[Net.Sockets.TcpListener]::new([ipaddress]::Loopback,0); $listener.Start(); $listener
        })
        try {
            $ports=@{home=$probes[0].LocalEndpoint.Port;daily=$probes[1].LocalEndpoint.Port;admin=$probes[2].LocalEndpoint.Port}
        } finally {foreach ($listener in $probes){$listener.Stop()}}
        $ports | ConvertTo-Json | Set-Content "$source/hyperv/dashboard-ports.json"
        & "$source/hyperv/Install-Portal.ps1" -Name $name -Directory $media -WebPort $ports.home -SkipProjectDrive
        if ((Invoke-WebRequest "http://localhost:$($ports.home)" -NoProxy).StatusCode -ne 200){throw 'Offline test portal unavailable.'}
    }
    Checkpoint-VM -VM $vm -SnapshotName 'uninstall fixture'
    $arguments=@{Name=$name;Directory=$media;KeepDisk=$keep}
    & "$PSScriptRoot/../uninstall-vm.ps1" @arguments
    if (!(Get-VM -Id $vm.Id) -or !(Test-Path $disk)){throw 'Preview changed the VM.'}
    & "$PSScriptRoot/../uninstall-vm.ps1" @arguments -Apply
    if ((Get-VM -Name $name -ErrorAction SilentlyContinue) -or (Test-Path $root) -or
        (Test-Path $disk) -ne $keep -or (Test-Path "$profileDir/keys/operator") -ne $keep -or
        !(Test-Path "$media/keep-user-file.txt") -or (Select-String -LiteralPath "$env:SystemRoot/System32/drivers/etc/hosts" -SimpleMatch -Pattern $vm.Id.ToString()) -or
        (Get-ScheduledTask -TaskName "$name *" -ErrorAction SilentlyContinue) -or (Test-Path "$profileDir/portal") -or
        (Test-Path (Join-Path ([Environment]::GetFolderPath('Programs')) "$name Management.lnk"))) {
        throw "Uninstall validation failed for $name."
    }
    if ($keep) {
        if ((Get-VHD -Path $disk).ParentPath) {throw 'Retained disk still depends on a checkpoint.'}
        if ((Get-Item -LiteralPath $disk).FullName -ne [IO.Path]::GetFullPath((Join-Path $diskHome "$name-system.vhdx"))){throw 'Unexpected disk path.'}
        Remove-Item -LiteralPath $disk -Force
    }
    if ((Resolve-Path $profileDir).Path -ne [IO.Path]::GetFullPath((Join-Path ([IO.Path]::GetTempPath()) $name))) {throw 'Unexpected test profile.'}
    Remove-Item -LiteralPath $profileDir -Recurse -Force
    Write-Output "Passed preview, checkpoint merge and uninstall with KeepDisk=$keep."
}

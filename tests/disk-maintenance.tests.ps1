#Requires -Version 7.2
# Failure-injection tests: no Docker, WSL or real disk-management operations.
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path $PSScriptRoot) 'compact-docker-disk.ps1')
$realNative = ${function:Invoke-DiskNative}
$realMultica = ${function:Get-DiskMultica}
$temporary = Join-Path ([IO.Path]::GetTempPath()) ('multica-disk-tests-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temporary | Out-Null
$fixture = Join-Path $temporary 'fixture.vhdx'
[IO.File]::WriteAllText($fixture, 'fixture; not a disk')
$script:Checks = 0
function Assert-Disk($Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
function Reset-DiskFixture([string]$Fault = '', [bool]$Multica = $false) {
    $script:Fault = $Fault
    $script:Events = [Collections.Generic.List[string]]::new()
    $script:Running = [Collections.Generic.HashSet[string]]::new()
    [void]$script:Running.Add('one'); [void]$script:Running.Add('two')
    $script:Desktop = $true
    $script:Daemon = $Multica
    $script:TaskEnabled = $Multica
    $script:DetachAttempts = 0
    $script:Context = @{Vhd=$fixture; BeforeBytes=(Get-Item $fixture).Length; Mount='/data';
        Containers=@('one','two'); StoppedContainers=@('stopped'); Multica=$null;
        RecoveryNeeded=$false; DesktopStopAttempted=$false; MountedByUs=$false}
    if ($Multica) {
        $script:Context.Multica = @{Root='fixture';Manager='manager';Pwsh='pwsh';Supervisor='supervisor';
            TaskName='fixture-task';TaskEnabled=$true;DaemonWasRunning=$true}
    }
}
function Get-DiskContext {
    param($Applying,$DiskPath,$Root,$Mount)
    if ($script:Fault -eq 'preflight') { throw 'fixture preflight failure' }
    return $script:Context
}
function Invoke-DiskNative {
    param([string]$Executable,[string[]]$Arguments,[int]$TimeoutSeconds)
    $script:Events.Add($Executable + ' ' + ($Arguments -join ' '))
    switch ($Executable) {
        'pwsh' {
            $index = [Array]::IndexOf($Arguments, '-Action')
            $action = $Arguments[$index+1]
            if ($script:Fault -eq $action.ToLowerInvariant()) { throw "fixture $action failure" }
            switch ($action) {
                'Stop' { $script:Running.Clear();$script:TaskEnabled=$false;$script:Daemon=$false }
                'Status' { return @{daemon=$(if($script:Daemon){'running'}else{'stopped'});active_tasks=0}|ConvertTo-Json }
            }
        }
        'supervisor' { $script:Daemon=$true }
        'wsl' {
            if ($Arguments -contains 'fstrim' -and $script:Fault -eq 'trim') { throw 'fixture trim failure' }
            if ($Arguments -contains '--shutdown' -and $script:Fault -eq 'shutdown') { throw 'fixture shutdown failure' }
            if ($Arguments -contains '--list' -and $script:Fault -eq 'wslstillrunning') { return 'docker-desktop' }
        }
        'docker' {
            switch ($Arguments[0]) {
                'ps' { return (@($script:Running) -join "`n") }
                'stop' {
                    if ($script:Fault -eq 'containers') { throw 'fixture container stop failure' }
                    foreach ($id in ($Arguments | Select-Object -Skip 3)) { [void]$script:Running.Remove($id) }
                }
                'start' {
                    if ($script:Fault -eq 'restartcontainers') { throw 'fixture container restart failure' }
                    foreach ($id in ($Arguments | Select-Object -Skip 1)) { [void]$script:Running.Add($id) }
                }
                'info' { if (-not $script:Desktop) { throw 'fixture engine unavailable' }; return 'linux' }
                'desktop' {
                    if ($Arguments[1] -eq 'stop') {
                        $script:Desktop=$false
                        if ($script:Fault -eq 'desktop') { throw 'fixture Desktop stop failure' }
                    } else {
                        if ($script:Fault -eq 'restartdesktop') { throw 'fixture Desktop restart failure' }
                        $script:Desktop=$true
                        # Model Docker's restart policy for a previously stopped app.
                        [void]$script:Running.Add('stopped')
                    }
                }
            }
        }
        default { throw 'Unexpected executable in fixture' }
    }
    return ''
}
function Get-VHD { param($Path,$ErrorAction)
    $script:Events.Add('inspect-vhd')
    return @{Attached=($script:Fault -eq 'attached');VhdType='Dynamic'}
}
function Mount-VHD { param($Path,[switch]$ReadOnly,[switch]$NoDriveLetter,$ErrorAction)
    $script:Events.Add('mount-readonly')
    Assert-Disk ($ReadOnly -and $NoDriveLetter) 'VHD was not attached read-only'
    if ($script:Fault -eq 'mount') { throw 'fixture mount failure' }
}
function Optimize-VHD { param($Path,$Mode,$ErrorAction)
    $script:Events.Add('optimize')
    if ($script:Fault -in @('optimize','optimize-detach','restartdesktop','restartcontainers')) { throw 'fixture optimize failure' }
}
function Dismount-VHD { param($Path,$ErrorAction)
    $script:Events.Add('detach')
    $script:DetachAttempts++
    if ($script:Fault -eq 'detach' -or ($script:Fault -eq 'optimize-detach' -and $script:DetachAttempts -eq 1)) { throw 'fixture detach failure' }
}
function Enable-ScheduledTask { param($TaskName,$ErrorAction) $script:TaskEnabled=$true }
function Disable-ScheduledTask { param($TaskName,$ErrorAction) $script:TaskEnabled=$false }

try {
    $pwsh = Join-Path $PSHOME 'pwsh.exe'
    $failure = ''
    try { $null = & $realNative $pwsh @('-NoProfile','-NonInteractive','-Command',"[Console]::Error.Write('private-fixture');exit 9") }
    catch { $failure=$_.Exception.Message }
    Assert-Disk ($failure -match 'exit 9' -and $failure -notmatch 'private-fixture') 'Native nonzero exit was lost or private stderr leaked'
    $script:Checks++
    $failure=''
    try { $null = & $realNative $pwsh @('-NoProfile','-NonInteractive','-Command','Start-Sleep 30') -TimeoutSeconds 1 }
    catch { $failure=$_.Exception.Message }
    Assert-Disk ($failure -match 'timed out') 'Native timeout was not detected'
    $script:Checks++

    Assert-Disk ($null -eq (& $realMultica (Join-Path $temporary 'absent'))) 'Missing Multica did not select generic mode'
    $partial = Join-Path $temporary 'partial'
    New-Item -ItemType Directory -Path $partial | Out-Null
    $failure=''
    try { $null = & $realMultica $partial } catch { $failure=$_.Exception.Message }
    Assert-Disk ($failure -match 'Incomplete Multica') 'Partial Multica setup was silently skipped'
    $script:Checks++

    Reset-DiskFixture
    Invoke-DockerDiskCompaction
    Assert-Disk ($script:Events.Count -eq 0) 'Check-only mode performed maintenance'
    $script:Checks++

    foreach ($multica in @($false,$true)) {
        Reset-DiskFixture -Multica $multica
        Invoke-DockerDiskCompaction -Apply
        Assert-Disk ($script:Events -contains 'optimize') 'Success never compacted'
        Assert-Disk ($script:Events.IndexOf('detach') -gt $script:Events.IndexOf('optimize')) 'Read-only attachment was not released'
        Assert-Disk ($script:Desktop -and $script:Running.SetEquals([string[]]@('one','two'))) 'Original container states were not restored'
        if ($multica) { Assert-Disk ($script:Daemon -and $script:TaskEnabled) 'Multica was not restored' }
        else { Assert-Disk (-not @($script:Events | Where-Object {$_ -match '^pwsh |^supervisor '}).Count) 'Generic mode invoked Multica' }
        $script:Checks++
    }
    Reset-DiskFixture -Multica $true
    $script:Context.Multica.TaskEnabled=$false
    Invoke-DockerDiskCompaction -Apply
    Assert-Disk (-not $script:TaskEnabled -and $script:Daemon) 'Previously disabled supervisor was enabled'
    $script:Checks++

    foreach ($fault in @('preflight','backup','stop','containers','trim','desktop','shutdown','wslstillrunning','attached','mount','optimize','optimize-detach','detach','restartdesktop','restartcontainers')) {
        Reset-DiskFixture -Fault $fault -Multica ($fault -in @('backup','stop','trim'))
        $failure=''
        try { Invoke-DockerDiskCompaction -Apply } catch { $failure=$_.Exception.Message }
        Assert-Disk ([bool]$failure) "Failure was swallowed: $fault"
        if ($fault -in @('preflight','backup','stop','containers','trim','desktop','shutdown','wslstillrunning','attached','mount')) {
            Assert-Disk ($script:Events -notcontains 'optimize') "Compaction followed a failed prerequisite: $fault"
        }
        if ($fault -in @('preflight','backup','stop','containers','trim')) {
            Assert-Disk (-not @($script:Events | Where-Object {$_ -eq 'docker desktop stop --timeout 120'}).Count) "Docker stopped after a prerequisite failed: $fault"
        }
        if ($fault -notin @('detach','restartdesktop','restartcontainers')) {
            Assert-Disk ($script:Desktop -and $script:Running.SetEquals([string[]]@('one','two'))) "Services were not restored after $fault"
        }
        if ($fault -in @('restartdesktop','restartcontainers','detach')) {
            Assert-Disk ($failure -match 'restoration also needs attention') "Recovery failure was hidden: $fault"
        }
        if ($fault -eq 'optimize-detach') {
            Assert-Disk ($failure -match 'optimize failure' -and $failure -match 'detach failure' -and $script:DetachAttempts -eq 2) 'Lost original failure or failed to retry owned disk detach'
        }
        $script:Checks++
    }
    Write-Host "$script:Checks disk-maintenance test groups passed. No live services or disks changed."
} finally {
    $resolved = [IO.Path]::GetFullPath($temporary)
    $parent = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    if (-not $resolved.StartsWith($parent,[StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($resolved) -notlike 'multica-disk-tests-*') { throw 'Unexpected fixture cleanup path' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}

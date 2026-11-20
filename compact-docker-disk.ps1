#Requires -Version 7.2
[CmdletBinding()]
param(
    [switch]$Apply,
    [string]$VhdPath,
    [string]$MulticaRoot = (Join-Path $env:USERPROFILE '.multica/local-ops'),
    [string]$TrimMount = '/mnt/docker-desktop-disk'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-DiskNative {
    param([string]$Executable, [string[]]$Arguments, [int]$TimeoutSeconds = 180)
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $Executable
    $start.UseShellExecute = $false
    $start.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.RedirectStandardInput = $true
    $start.Environment['WSL_UTF8'] = '1'
    foreach ($argument in $Arguments) { $start.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $start
    try {
        if (-not $process.Start()) { throw 'Could not start maintenance command' }
        $process.StandardInput.Close()
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            $process.Kill($true)
            $process.WaitForExit()
            throw "$([IO.Path]::GetFileName($Executable)) timed out; its server-side operation may still be finishing"
        }
        $outputText = $stdout.GetAwaiter().GetResult()
        $null = $stderr.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0) {
            # Diagnostics from installed applications can contain private data.
            throw "$([IO.Path]::GetFileName($Executable)) failed (exit $($process.ExitCode))"
        }
        return $outputText.Replace("`0", '')
    } finally { $process.Dispose() }
}

function Get-DiskMultica {
    param([string]$Root)
    if (-not (Test-Path -LiteralPath $Root)) { return $null }
    foreach ($file in @('manage.ps1','scripts/common.ps1','install-state.json','settings.json','config.json','compose.yml','.env')) {
        if (-not (Test-Path -LiteralPath (Join-Path $Root $file) -PathType Leaf)) {
            throw "Incomplete Multica installation: missing $file. No maintenance has started."
        }
    }
    $state = Get-Content -LiteralPath (Join-Path $Root 'install-state.json') -Raw | ConvertFrom-Json
    if (-not (Test-Path -LiteralPath $state.cli -PathType Leaf)) { throw 'Multica CLI is missing' }
    $supervisor = Join-Path (Split-Path $state.cli) 'supervisor.exe'
    if (-not (Test-Path -LiteralPath $supervisor -PathType Leaf)) { throw 'Multica supervisor is missing' }
    $task = Get-ScheduledTask -TaskName $state.task_name -ErrorAction Stop
    $pwsh = Join-Path $PSHOME 'pwsh.exe'
    $manager = Join-Path $Root 'manage.ps1'
    $status = Invoke-DiskNative $pwsh @('-NoProfile','-NonInteractive','-File',$manager,'-Action','Status','-Root',$Root) | ConvertFrom-Json
    if ($status.active_tasks -ne 0) { throw 'Multica has active work; finish or cancel it before maintenance' }
    if ($status.daemon -notin @('running','stopped')) { throw 'Multica daemon state is uncertain' }
    return @{Root=$Root; Manager=$manager; Pwsh=$pwsh; TaskName=$state.task_name;
        TaskEnabled=[bool]$task.Settings.Enabled; DaemonWasRunning=($status.daemon -eq 'running'); Supervisor=$supervisor}
}

function Get-DiskContext {
    param([bool]$Applying, [string]$DiskPath, [string]$Root, [string]$Mount)
    if (-not $IsWindows) { throw 'This script supports Docker Desktop with WSL2 on Windows' }
    if ($Applying) {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        if (-not ([Security.Principal.WindowsPrincipal]::new($identity)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw 'Run PowerShell 7 as Administrator to apply disk maintenance'
        }
    }
    foreach ($command in @('docker','wsl','Optimize-VHD','Mount-VHD','Dismount-VHD','Get-VHD')) {
        $null = Get-Command $command -ErrorAction Stop
    }
    $desktop = Invoke-DiskNative docker @('desktop','status','--format','json') | ConvertFrom-Json
    if ($desktop.Status -ne 'running') { throw 'Start Docker Desktop before running this script' }
    $endpoint = (Invoke-DiskNative docker @('context','inspect','--format','{{.Endpoints.docker.Host}}')).Trim()
    if ($endpoint -notmatch '^npipe://.*?/pipe/(dockerDesktopLinuxEngine|docker_engine)$') {
        throw 'Current Docker context is not a supported local Desktop engine'
    }
    if ((Invoke-DiskNative docker @('info','--format','{{.OSType}}')).Trim() -ne 'linux') { throw 'Switch Docker Desktop to Linux containers' }
    if (-not $DiskPath) {
        $candidates = @(
            (Join-Path $env:LOCALAPPDATA 'Docker/wsl/disk/docker_data.vhdx'),
            (Join-Path $env:LOCALAPPDATA 'Docker/wsl/data/ext4.vhdx')
        ) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }
        if (@($candidates).Count -ne 1) { throw 'Cannot identify one Docker data disk; supply -VhdPath explicitly' }
        $DiskPath = @($candidates)[0]
    }
    $disk = Get-Item -LiteralPath $DiskPath -ErrorAction Stop
    if ($disk.PSIsContainer -or $disk.Extension -ne '.vhdx' -or ($disk.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw 'Supply a regular local Docker data .vhdx file'
    }
    if ($disk.FullName.StartsWith('\\')) { throw 'Network VHD paths are unsupported' }
    $distros = @((Invoke-DiskNative wsl @('--list','--running','--quiet')) -split '\r?\n' | ForEach-Object Trim | Where-Object {$_})
    if (@($distros | Where-Object {$_ -notin @('docker-desktop','docker-desktop-data')}).Count -gt 0) {
        throw 'Other WSL distributions are running. Save and stop that work first; this script will not shut it down for you.'
    }
    if ($Mount -notmatch '^/[a-zA-Z0-9_./-]+$' -or $Mount -match '/\.\.?(/|$)') { throw 'Invalid Docker trim mount' }
    $mountedAt = (Invoke-DiskNative wsl @('-d','docker-desktop','-u','root','--','findmnt','-n','--first-only','--raw','-o','TARGET','--target',$Mount)).Trim()
    if ($mountedAt -ne $Mount) { throw 'Docker trim path is not its own mounted filesystem; check -TrimMount' }
    $null = Invoke-DiskNative wsl @('-d','docker-desktop','-u','root','--','fstrim','--dry-run',$Mount)
    $multica = Get-DiskMultica $Root
    $containers = @((Invoke-DiskNative docker @('ps','-q','--no-trunc')) -split '\r?\n' | Where-Object {$_})
    $allContainers = @((Invoke-DiskNative docker @('ps','-aq','--no-trunc')) -split '\r?\n' | Where-Object {$_})
    return @{Vhd=$disk.FullName; BeforeBytes=$disk.Length; Mount=$Mount; Multica=$multica;
        Containers=$containers; StoppedContainers=@($allContainers | Where-Object {$_ -notin $containers});
        RecoveryNeeded=$false; DesktopStopAttempted=$false; MountedByUs=$false}
}

function Stop-DiskWorkloads {
    param($Context)
    if ($Context.Multica) {
        $m = $Context.Multica
        $null = Invoke-DiskNative $m.Pwsh @('-NoProfile','-NonInteractive','-File',$m.Manager,'-Action','Backup','-Root',$m.Root) -TimeoutSeconds 600
    }
    # Set before the first stop attempt: it may partially succeed and then fail.
    $Context.RecoveryNeeded = $true
    if ($Context.Multica) {
        $m = $Context.Multica
        $null = Invoke-DiskNative $m.Pwsh @('-NoProfile','-NonInteractive','-File',$m.Manager,'-Action','Stop','-Root',$m.Root)
    }
    $running = @((Invoke-DiskNative docker @('ps','-q','--no-trunc')) -split '\r?\n' | Where-Object {$_})
    if ($running.Count) {
        # No forced SIGKILL deadline. A hung graceful stop aborts maintenance.
        $null = Invoke-DiskNative docker (@('stop','--time','-1') + $running) -TimeoutSeconds 180
    }
    if ((Invoke-DiskNative docker @('ps','-q')).Trim()) { throw 'Containers are still running; refusing maintenance' }
}

function Invoke-DiskTrim { param($Context)
    $null = Invoke-DiskNative wsl @('-d','docker-desktop','-u','root','--','fstrim','-v',$Context.Mount) -TimeoutSeconds 600
}

function Stop-DiskEngine { param($Context)
    $Context.DesktopStopAttempted = $true
    $null = Invoke-DiskNative docker @('desktop','stop','--timeout','120') -TimeoutSeconds 150
    $null = Invoke-DiskNative wsl @('--shutdown')
    if ((Invoke-DiskNative wsl @('--list','--running','--quiet')).Trim()) { throw 'WSL did not stop; refusing compaction' }
}

function Compress-Disk { param($Context)
    $disk = Get-VHD -Path $Context.Vhd -ErrorAction Stop
    if ($disk.Attached -or $disk.VhdType -ne 'Dynamic') { throw 'Docker data disk must be detached and dynamically expanding' }
    $null = Mount-VHD -Path $Context.Vhd -ReadOnly -NoDriveLetter -ErrorAction Stop
    $Context.MountedByUs = $true
    $errors = [Collections.Generic.List[string]]::new()
    try { Optimize-VHD -Path $Context.Vhd -Mode Full -ErrorAction Stop }
    catch { $errors.Add($_.Exception.Message) }
    finally {
        try {
            Dismount-VHD -Path $Context.Vhd -ErrorAction Stop
            $Context.MountedByUs = $false
        } catch { $errors.Add("Disk detach failed: $($_.Exception.Message)") }
    }
    if ($errors.Count) { throw ($errors -join '; ') }
}

function Restore-DiskWorkloads { param($Context)
    if (-not $Context.RecoveryNeeded) { return }
    if ($Context.MountedByUs) {
        Dismount-VHD -Path $Context.Vhd -ErrorAction Stop
        $Context.MountedByUs = $false
    }
    $errors = [Collections.Generic.List[string]]::new()
    $engineReady = $true
    try {
        if ($Context.DesktopStopAttempted) {
            $null = Invoke-DiskNative docker @('desktop','start','--timeout','120') -TimeoutSeconds 150
            # Desktop's UI can start before its Linux engine is ready.
            $deadline = [DateTime]::UtcNow.AddSeconds(120)
            while ($true) {
                try {
                    $null = Invoke-DiskNative docker @('info','--format','{{.OSType}}') -TimeoutSeconds 10
                    break
                } catch {
                    if ([DateTime]::UtcNow -ge $deadline) { throw 'Docker engine did not become ready after Desktop restart' }
                    Start-Sleep -Seconds 2
                }
            }
        } else {
            $null = Invoke-DiskNative docker @('info','--format','{{.OSType}}')
        }
    } catch { $errors.Add("Docker restart: $($_.Exception.Message)"); $engineReady = $false }
    if ($engineReady) {
        try {
            $runningNow = @((Invoke-DiskNative docker @('ps','-q','--no-trunc')) -split '\r?\n' | Where-Object {$_})
            $unexpected = @($Context.StoppedContainers | Where-Object {$_ -in $runningNow})
            # Docker's "always" policy can restart previously stopped containers.
            if ($unexpected.Count) { $null = Invoke-DiskNative docker (@('stop','--time','-1') + $unexpected) }
        } catch { $errors.Add("Restore stopped containers: $($_.Exception.Message)") }
        try {
            if ($Context.Containers.Count) { $null = Invoke-DiskNative docker (@('start') + $Context.Containers) }
        } catch { $errors.Add("Restore running containers: $($_.Exception.Message)") }
    }
    if ($Context.Multica) {
        $m = $Context.Multica
        # Restore the previous enabled state; do not enable a previously disabled task.
        try {
            if ($m.TaskEnabled) { Enable-ScheduledTask -TaskName $m.TaskName -ErrorAction Stop | Out-Null }
            else { Disable-ScheduledTask -TaskName $m.TaskName -ErrorAction Stop | Out-Null }
        } catch { $errors.Add("Restore Multica task: $($_.Exception.Message)") }
        if ($m.DaemonWasRunning -and $engineReady) {
            try {
                $null = Invoke-DiskNative $m.Supervisor @((Join-Path $m.Root 'config.json'))
                $status = Invoke-DiskNative $m.Pwsh @('-NoProfile','-NonInteractive','-File',$m.Manager,'-Action','Status','-Root',$m.Root) | ConvertFrom-Json
                if ($status.daemon -ne 'running') { throw 'Multica daemon did not recover' }
            } catch { $errors.Add("Restore Multica daemon: $($_.Exception.Message)") }
        }
    }
    if ($engineReady) {
        try {
            $running = @((Invoke-DiskNative docker @('ps','-q','--no-trunc')) -split '\r?\n' | Where-Object {$_})
            if (@($Context.Containers | Where-Object {$_ -notin $running}).Count) { throw 'Some original containers did not restart' }
            if (@($Context.StoppedContainers | Where-Object {$_ -in $running}).Count) { throw 'Some previously stopped containers are running' }
        } catch { $errors.Add($_.Exception.Message) }
    }
    if ($errors.Count) { throw ($errors -join '; ') }
}

function Invoke-DockerDiskCompaction {
    param([switch]$Apply, [string]$VhdPath, [string]$MulticaRoot, [string]$TrimMount)
    $context = Get-DiskContext -Applying ([bool]$Apply) -DiskPath $VhdPath -Root $MulticaRoot -Mount $TrimMount
    Write-Host ("Disk: {0} ({1:N2} GiB)" -f $context.Vhd, ($context.BeforeBytes / 1GB))
    Write-Host $(if ($context.Multica) {'Multica detected: back up, stop and restore its prior state.'} else {'Multica absent: use generic Docker maintenance.'})
    if (-not $Apply) { Write-Host 'Checks passed. No maintenance performed. Use -Apply to stop workloads and compact.'; return }
    $failure = $null
    $recoveryFailure = $null
    $stage = 'stopping workloads'
    try {
        Stop-DiskWorkloads $context
        $stage = 'trimming unused blocks'; Invoke-DiskTrim $context
        $stage = 'stopping Docker and WSL'; Stop-DiskEngine $context
        $stage = 'compacting the disk'; Compress-Disk $context
    } catch { $failure = "Maintenance failed while $stage`: $($_.Exception.Message)" }
    finally {
        try { Restore-DiskWorkloads $context }
        catch { $recoveryFailure = "Service restoration also needs attention: $($_.Exception.Message)" }
    }
    if ($failure -or $recoveryFailure) {
        throw (@($failure,$recoveryFailure | Where-Object {$_}) -join "`n")
    }
    $after = (Get-Item -LiteralPath $context.Vhd -ErrorAction Stop).Length
    Write-Host ("Finished. VHD: {0:N2} -> {1:N2} GiB. Original services restored." -f ($context.BeforeBytes/1GB),($after/1GB))
}

if ($MyInvocation.InvocationName -ne '.') {
    try { Invoke-DockerDiskCompaction -Apply:$Apply -VhdPath $VhdPath -MulticaRoot $MulticaRoot -TrimMount $TrimMount }
    catch { Write-Error -Message $_.Exception.Message -ErrorAction Continue; exit 1 }
}

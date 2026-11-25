#Requires -Version 7.3
param([ValidatePattern('^[A-Za-z0-9-]{1,50}$')][string]$Name='Multica-Ubuntu',
    [Parameter(Mandatory)][ValidateSet('status','check','start','stop','restart','install','boot-on','boot-off')][string]$Action,
    [switch]$Elevated,[guid]$RequestId)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$true
$root=Join-Path $env:ProgramFiles "MulticaVM/$Name"
$config=Get-Content -LiteralPath "$root/portal/install.json" -Raw | ConvertFrom-Json
$state=Get-Content -LiteralPath "$root/vm.json" -Raw | ConvertFrom-Json
if ($state.id -ne $config.id -or $config.name -ne $Name) { throw 'VM identity mismatch.' }
$profileDir=Split-Path $config.directory
$ssh=@('-o','BatchMode=yes','-o','IdentitiesOnly=yes','-o','ConnectTimeout=3','-o','StrictHostKeyChecking=yes',
    '-o',"HostKeyAlias=$Name",'-o',"UserKnownHostsFile=$profileDir/known_hosts",'-i',"$profileDir/keys/operator","multicaops@$($state.address)")
$updater="$PSScriptRoot/update-vm.ps1"
function Get-Plan { & $updater -Name $Name -Directory $config.directory -Plan -PassThru }
function Get-GuestReport([switch]$Idle) {
    if ($Idle) {
        $PSNativeCommandUseErrorActionPreference=$false
        $details=Get-Content -Raw "$PSScriptRoot/portal-status.py" | ssh @ssh 'sudo python3 - idle' 2>&1
        if ($LASTEXITCODE){throw "Cannot proceed: $(($details | Select-Object -Last 3) -join ' ')"}
    } else {
        # During boot SSH can report connection refused before the JSON status.
        Get-Content -Raw "$PSScriptRoot/portal-status.py" | ssh @ssh 'sudo python3 -' 2>$null
    }
}
if ($Action -eq 'status') {
    $hostState=Get-Content "$root/host-status.json" -Raw | ConvertFrom-Json
    $report=@{vm=$hostState.vm;boot=$hostState.boot;checked=([datetimeoffset]$hostState.checked).ToUniversalTime().ToString('o');guest=$null;detail=''}
    if ($hostState.vm -eq 'Running') {
        try { $report.guest=Get-GuestReport | ConvertFrom-Json } catch { $report.detail='Guest services are starting or the SSH connection is unavailable.' }
    }
    $report | ConvertTo-Json -Depth 6 -Compress
    return
}
if ($Action -eq 'check') {
    if ((Get-Content "$root/host-status.json" -Raw | ConvertFrom-Json).vm -ne 'Running') {
        $latest=Invoke-RestMethod 'https://api.github.com/repos/multica-ai/multica/releases/latest'
        "Latest stable release: $($latest.tag_name). Start the VM to compare its installed version."
    } else {
        $plan=Get-Plan
        if ($plan.available) { "Available: $($plan.tag). Installed commit: $($plan.current)." } else { "Already up to date ($($plan.tag))." }
    }
    return
}
if (!$Elevated) {
    $RequestId=[guid]::NewGuid()
    $arg='-NoLogo -NoProfile -NonInteractive -File "{0}" -Name {1} -Action {2} -Elevated -RequestId {3}' -f $PSCommandPath,$Name,$Action,$RequestId
    $proc=Start-Process (Get-Process -Id $PID).Path -Verb RunAs -WindowStyle Hidden -ArgumentList $arg -Wait -PassThru
    $receipt=Get-Content "$root/portal/action-result.json" -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
    if (!$receipt -or $receipt.requestId -ne "$RequestId" -or $receipt.action -ne $Action) { throw 'Operation ended without a matching result.' }
    $receipt.message
    if ($proc.ExitCode -or !$receipt.ok) { exit 1 }
    return
}
$vm=Get-VM -Id $state.id
if ($vm.Name -ne $Name) {throw 'Unexpected VM name.'}
$lock=[IO.File]::Open("$root/portal/operation.lock",'OpenOrCreate','ReadWrite','None')
try {
    $ok=$false
    $message=''
    switch ($Action) {
      'boot-on' { Enable-ScheduledTask -TaskName "$Name unattended boot" | Out-Null; $message='VM startup at Windows boot enabled.' }
      'boot-off' { Disable-ScheduledTask -TaskName "$Name unattended boot" | Out-Null; $message='VM startup at Windows boot disabled.' }
      'install' {
        $preparedBackup=$null
        $plan=Get-Plan
        if (!$plan.available) { $message="Already up to date ($($plan.tag))."; break }
        Get-GuestReport -Idle
        . "$PSScriptRoot/Dashboard-Health.ps1"
        $before=Get-DashboardHealth $config -RetrySeconds 5
        $applyError=$null
        try {
            ssh @ssh 'sudo bash /opt/multica-local/hyperv/admin.sh stop'
            & $updater -Apply -Version $plan.tag -Name $Name -Directory $config.directory -PreparedBackupId ([ref]$preparedBackup) -WarningVariable applyWarnings
        } catch { $applyError=$_.Exception.Message }
        try {
            $PSNativeCommandUseErrorActionPreference=$false
            $adminOutput=ssh @ssh 'sudo sh -ec "if test -e /var/lib/multica-local/update-pending.json; then echo Interrupted-migration-review-the-update-backup >&2; exit 1; fi; exec python3 /opt/multica-local/hyperv/admin.py"' 2>&1
            if ($LASTEXITCODE){throw (($adminOutput | Select-Object -Last 3) -join ' ')}
        } catch {
            if ($applyError){throw "$applyError. Admin recovery also failed: $($_.Exception.Message). See $root/updates."}
            throw "Upgrade applied ($($plan.tag)); admin restart failed: $($_.Exception.Message). Backup receipts: $root/updates."
        } finally { $PSNativeCommandUseErrorActionPreference=$true }
        if ($applyError){throw $applyError}
        $after=Get-DashboardHealth $config -RetrySeconds 45
        $message=Compare-DashboardHealth $before $after $plan.tag "$root/updates"
        if ($applyWarnings){$message+=" Warnings: $(($applyWarnings | Select-Object -Unique) -join '; ')"}
      }
      default {
        $updateLock=[IO.File]::Open("$root/update.lock",'OpenOrCreate','ReadWrite','None')
        try {
            if ($Action -in 'stop','restart' -and $vm.State -ne 'Off') {
                Get-GuestReport -Idle
                Stop-VM -VM $vm -Confirm:$false -ErrorAction Stop
            }
            if ($Action -in 'start','restart') { & "$root/Start-Guest.ps1" -VMId $vm.Id }
        } finally { $updateLock.Dispose() }
        $message="VM state: $((Get-VM -Id $vm.Id).State)."
      }
    }
    $ok=$true
} catch {
    $message=$_.Exception.Message
    if ($Action -eq 'install' -and $preparedBackup) {
        $restore="& '" + $updater.Replace("'","''") + "' -Name $Name -Restore -BackupId $preparedBackup"
        $message="To restore the whole VM, run in administrator PowerShell:`n$restore`n`n$message"
    }
    throw
} finally {
    try {
        @{requestId="$RequestId";action=$Action;message=$message;ok=$ok} | ConvertTo-Json | Set-Content "$root/portal/action-result.json"
        & "$root/Sync-GuestAddress.ps1" -VMId $vm.Id
    } finally { $lock.Dispose() }
}

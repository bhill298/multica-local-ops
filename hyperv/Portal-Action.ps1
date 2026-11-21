#Requires -Version 7.3
param([ValidatePattern('^[A-Za-z0-9-]{1,50}$')][string]$Name='Multica-Ubuntu',
    [Parameter(Mandatory)][ValidateSet('status','check','start','stop','restart','install','boot-on','boot-off')][string]$Action,
    [switch]$Elevated)
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
        try { Get-Content -Raw "$PSScriptRoot/portal-status.py" | ssh @ssh 'sudo python3 - idle' }
        catch { throw 'Both workspaces must be reachable and have no unfinished jobs. Check the queues before retrying.' }
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
    $arg='-NoLogo -NoProfile -NonInteractive -File "{0}" -Name {1} -Action {2} -Elevated' -f $PSCommandPath,$Name,$Action
    $proc=Start-Process (Get-Process -Id $PID).Path -Verb RunAs -WindowStyle Hidden -ArgumentList $arg -Wait -PassThru
    $receipt=Get-Content "$root/portal/action-result.json" -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
    if ($proc.ExitCode -or !$receipt -or $receipt.action -ne $Action) { throw "Operation failed. $($receipt.message)" }
    $receipt.message
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
        $plan=Get-Plan
        if (!$plan.available) { $message="Already up to date ($($plan.tag))."; break }
        Get-GuestReport -Idle
        try {
            ssh @ssh 'sudo bash /opt/multica-local/hyperv/admin.sh stop'
            & $updater -Apply -Version $plan.tag -Name $Name -Directory $config.directory
        }
        finally {
            ssh @ssh 'sudo sh -ec "if test -e /var/lib/multica-local/update-pending.json; then echo Interrupted-migration-review-the-update-backup >&2; exit 1; fi; exec python3 /opt/multica-local/hyperv/admin.py"'
        }
        $message="Installed $($plan.tag). Backup receipts are under $root/updates."
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
} catch { $message=$_.Exception.Message; throw } finally {
    try {
        @{action=$Action;message=$message;ok=$ok} | ConvertTo-Json | Set-Content "$root/portal/action-result.json"
        & "$root/Sync-GuestAddress.ps1" -VMId $vm.Id
    } finally { $lock.Dispose() }
}

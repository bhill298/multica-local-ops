param([Parameter(Mandatory)][string]$Fixture)
$ErrorActionPreference='Stop'
$name='Test-VM'
$root=Join-Path $Fixture "MulticaVM/$name"
$portal=Join-Path $root 'portal'
$null=New-Item -ItemType Directory -Path $portal -Force
Copy-Item "$PSScriptRoot/../hyperv/Portal-Action.ps1" $portal
$vmId=[guid]::NewGuid()
$backupId=[guid]::NewGuid()
@{id=$vmId;address='localhost'} | ConvertTo-Json | Set-Content "$root/vm.json"
@{id=$vmId;name=$name;directory=$Fixture} | ConvertTo-Json | Set-Content "$portal/install.json"
Set-Content "$root/Sync-GuestAddress.ps1" 'param($VMId)'
Set-Content "$portal/portal-status.py" ''
Set-Content "$portal/Dashboard-Health.ps1" @'
function Get-DashboardHealth($Config,$RetrySeconds) { return @() }
function Compare-DashboardHealth { throw 'Dashboard returned 503' }
'@
Set-Content "$portal/update-vm.ps1" @'
[CmdletBinding()]param([switch]$Plan,[switch]$PassThru,[switch]$Apply,$Version,$Name,$Directory,[ref]$PreparedBackupId)
if ($Plan) { return @{available=$true;tag='v1.0.0'} }
if ($failure -eq 'staging') { throw 'Staging failed' }
$PreparedBackupId.Value=$backupId
if ($failure -eq 'activation') { throw 'Activation failed' }
'@
function Get-VM($Id) { @{Name=$name;Id=$Id} }
function ssh {
    $global:LASTEXITCODE=0
    if ($failure -eq 'admin' -and $args[-1] -like '*admin.py*') { $global:LASTEXITCODE=1; 'Admin failed' }
}
$originalProgramFiles=$env:ProgramFiles
try {
    $env:ProgramFiles=$Fixture
    foreach ($failure in 'staging','activation','admin','dashboard') {
        $requestId=[guid]::NewGuid()
        try { & "$portal/Portal-Action.ps1" -Name $name -Action install -Elevated -RequestId $requestId } catch {}
        $result=Get-Content "$portal/action-result.json" -Raw | ConvertFrom-Json
        $diagnostic=@{staging='Staging failed';activation='Activation failed';admin='Admin failed';dashboard='Dashboard returned 503'}[$failure]
        if ($result.ok -or $result.requestId -ne "$requestId" -or !$result.message.Contains($diagnostic)) {
            throw "Missing $failure failure in receipt: $($result.message)"
        }
        if ($failure -eq 'staging') {
            if ($result.message.Contains('-Restore')) {throw 'Offered a restore command before backup was ready.'}
            continue
        }
        $command=($result.message -split '\r?\n')[1]
        $tokens=$null; $errors=$null
        [void][Management.Automation.Language.Parser]::ParseInput($command,[ref]$tokens,[ref]$errors)
        if ($errors -or $tokens[1].Value -ne "$portal/update-vm.ps1" -or
            $command -notlike "* -Name $name -Restore -BackupId $backupId") {
            throw "Incorrect restore command for $failure failure: $command"
        }
    }
    # Simulate the elevation boundary and check the exact text sent to the Go portal.
    function Start-Process($FilePath,$ArgumentList,$Verb,$WindowStyle,[switch]$Wait,[switch]$PassThru) {
        if ($ArgumentList -notmatch '-RequestId ([0-9a-f-]{36})') {throw 'Missing request ID'}
        if (!$stale) {
            $result.requestId=$Matches[1]
            $result | ConvertTo-Json | Set-Content "$portal/action-result.json"
        }
        return @{ExitCode=1}
    }
    $stale=$false
    $display=& "$portal/Portal-Action.ps1" -Name $name -Action install
    if ($LASTEXITCODE -ne 1 -or $display -cne $result.message) {throw 'Portal lost the failure text or exit status.'}
    $stale=$true
    $reason=''
    try { & "$portal/Portal-Action.ps1" -Name $name -Action install } catch { $reason=$_.Exception.Message }
    if ($reason -ne 'Operation ended without a matching result.') {throw 'Portal reused an earlier result.'}
} finally { $env:ProgramFiles=$originalProgramFiles }

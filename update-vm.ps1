#Requires -Version 7.3
[CmdletBinding(DefaultParameterSetName='Plan')]
param(
    [Parameter(ParameterSetName='Plan')][switch]$Plan,
    [Parameter(ParameterSetName='Plan')][switch]$PassThru,
    [Parameter(Mandatory,ParameterSetName='Apply')][switch]$Apply,
    [Parameter(ParameterSetName='Apply')][ref]$PreparedBackupId,
    [Parameter(Mandatory,ParameterSetName='Restore')][switch]$Restore,
    [Parameter(Mandatory,ParameterSetName='Clear')][switch]$Clear,
    [Parameter(Mandatory,ParameterSetName='Promote')][switch]$PromoteInstalled,
    [Parameter(Mandatory,ParameterSetName='Restore')]
    [Parameter(Mandatory,ParameterSetName='Clear')][guid]$BackupId,
    [Parameter(ParameterSetName='Plan')][Parameter(ParameterSetName='Apply')]
    [ValidatePattern('^(latest|v\d+\.\d+\.\d+)$')][string]$Version='latest',
    [ValidatePattern('^[A-Za-z0-9-]{1,50}$')][string]$Name='Multica-Ubuntu',
    [string]$Directory="$env:LOCALAPPDATA/MulticaVM/media"
)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$true
if ($PSCmdlet.ParameterSetName -ne 'Plan' -and !($Apply -or $Restore -or $Clear -or $PromoteInstalled)) { throw 'Choose one update action.' }
$hostRoot=Join-Path $env:ProgramFiles "MulticaVM/$Name"
$state=Get-Content "$hostRoot/vm.json" -Raw | ConvertFrom-Json
if ($state.phase -ne 'installed') { throw 'Complete the VM installation first.' }
$profileRoot=Split-Path ([IO.Path]::GetFullPath($Directory))
$sshOptions=@('-o','BatchMode=yes','-o','IdentitiesOnly=yes','-o','ConnectTimeout=10',
    '-o',"HostKeyAlias=$Name",'-o','StrictHostKeyChecking=yes','-o',"UserKnownHostsFile=$profileRoot/known_hosts",
    '-i',"$profileRoot/keys/operator","multicaops@$($state.address)")

function Invoke-GuestUpdate([string[]]$Words) {
    # The remote shell receives only fixed action names and validated release references.
    $PSNativeCommandUseErrorActionPreference=$false
    $tail=[Collections.Generic.Queue[string]]::new()
    Get-Content -Raw "$PSScriptRoot/hyperv/update-release.py" | ssh @sshOptions "sudo python3 - $($Words -join ' ')" 2>&1 | ForEach-Object {
        $line=$_.ToString().Trim()
        if ($line) {
            if ($tail.Count -eq 4) {$null=$tail.Dequeue()}
            $tail.Enqueue($line.Substring(0,[Math]::Min(1600,$line.Length)))
        }
        if ($Words[0] -in 'status','installed-pins') {
            if ($_ -isnot [Management.Automation.ErrorRecord]) { $_ }
        } elseif ($line.StartsWith('Warning: ')) {
            Write-Warning $line.Substring(9)
        } else { Write-Host $line }
    }
    if ($LASTEXITCODE) { throw "Guest $($Words[0]) failed (exit $LASTEXITCODE): $($tail -join [Environment]::NewLine)" }
}

if ($PromoteInstalled) {
    $file=Join-Path $PSScriptRoot 'hyperv/initial-release.json'
    if (!(Test-Path -LiteralPath $file -PathType Leaf)) {
        if ((Test-Path -LiteralPath "$PSScriptRoot/.git") -and (Get-Command git -ErrorAction SilentlyContinue) -and
            (git -C $PSScriptRoot status --porcelain=v1 -- hyperv/initial-release.json)) {
            Write-Warning 'The pin file has a local deletion. Skipping promotion and auto-commit.'; return
        }
        throw 'Run -PromoteInstalled from the installer checkout.'
    }
    $pins=Invoke-GuestUpdate @('installed-pins') | ConvertFrom-Json
    & "$PSScriptRoot/hyperv/Promote-ReleasePins.ps1" -Pins $pins -Name $Name
    return
}

function Get-ImagePin([string]$Image,[string]$Tag) {
    $repo="multica-ai/$Image"
    try { $token=(Invoke-RestMethod "https://ghcr.io/token?service=ghcr.io&scope=repository:${repo}:pull").token }
    catch {throw "Registry authorization failed for $repo $Tag : $($_.Exception.Message)"}
    $headers=@{Authorization="Bearer $token";Accept='application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json'}
    try { $response=Invoke-WebRequest "https://ghcr.io/v2/$repo/manifests/$Tag" -Method Head -Headers $headers }
    catch {throw "Cannot resolve container manifest for $repo $Tag : $($_.Exception.Message)"}
    $digest=[string]($response.Headers['Docker-Content-Digest'] | Select-Object -First 1)
    if ($digest -cnotmatch '^sha256:[a-f0-9]{64}$') { throw "Missing digest for $Image $Tag." }
    "ghcr.io/$repo@$digest"
}

function Get-ReleasePins {
    $api='https://api.github.com/repos/multica-ai/multica'
    $route=if ($Version -eq 'latest') { 'latest' } else { "tags/$Version" }
    $release=Invoke-RestMethod "$api/releases/$route"
    $tag=$release.tag_name
    if ($release.draft -or $release.prerelease -or $tag -cnotmatch '^v\d+\.\d+\.\d+$') { throw 'Expected a published stable release.' }
    $sha=(Invoke-RestMethod "$api/commits/$tag").sha
    if ($sha -cnotmatch '^[a-f0-9]{40}$') { throw 'Invalid upstream commit.' }
    [pscustomobject]@{tag=$tag;commit=$sha;backend=(Get-ImagePin multica-backend $tag);frontend=(Get-ImagePin multica-web $tag)}
}

function Show-Backup {
    Write-Host "Backup ID: $BackupId"
    Write-Host "Checkpoint: $label ($($vm.Name)); backup directory: $folder"
    Write-Host "Export: $folder/export (ready only after Export-VMSnapshot completes)"
    Write-Host "Restore the whole VM: ./update-vm.ps1 -Name $Name -Restore -BackupId $BackupId"
    Write-Host "Delete this checkpoint and its export: ./update-vm.ps1 -Name $Name -Clear -BackupId $BackupId"
}

if ($Apply -or $Plan -or $PSCmdlet.ParameterSetName -eq 'Plan') {
    $old=Invoke-GuestUpdate @('status') | ConvertFrom-Json
    $next=Get-ReleasePins
    $available=$old.commit -ne $next.commit -or $old.backend -ne $next.backend -or $old.frontend -ne $next.frontend
    if ($available) { & "$PSScriptRoot/hyperv/Test-UpstreamSql.ps1" -Commit $next.commit }
    if ($PassThru) {
        return [pscustomobject]@{tag=$next.tag;current=$old.commit;target=$next.commit;available=$available}
    }
    Write-Host "Installed commit: $($old.commit)"
    Write-Host "Target $($next.tag): $($next.commit)"
    Write-Host "Backend: $($next.backend)"
    Write-Host "Frontend: $($next.frontend)"
    if (!$available) {
        Write-Host 'Already pinned to this release.'
        return
    }
    if (!$Apply) { Write-Host "To install: ./update-vm.ps1 -Name $Name -Apply -Version $($next.tag)"; return }
}
$identity=[Security.Principal.WindowsIdentity]::GetCurrent()
if (!([Security.Principal.WindowsPrincipal]::new($identity)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run Apply, Restore and Clear from an administrator PowerShell 7 terminal.'
}
$vm=Get-VM -Id $state.id
if ($vm.Name -ne $Name) { throw 'VM identity differs from the installation record.' }
$lock=[IO.File]::Open("$hostRoot/update.lock",'OpenOrCreate','ReadWrite','None')
try {
    if ($Apply) { $BackupId=[guid]::NewGuid() }
    $label="MulticaUpdate-$BackupId"
    $folder=Join-Path $hostRoot "updates/$BackupId"
    $receipt=Join-Path $folder receipt.json
    if ($Restore -or $Clear) {
        $record=Get-Content -LiteralPath $receipt -Raw | ConvertFrom-Json
        if ($record.vm -ne "$($vm.Id)" -or $record.id -ne "$BackupId") { throw 'Backup identity mismatch.' }
        $snap=Get-VMSnapshot -VM $vm | Where-Object Name -eq $label
        if ($snap -and ($snap.Count -gt 1 -or ($record.snapshot -and "$($snap.Id)" -ne $record.snapshot))) { throw 'Checkpoint identity mismatch.' }
        if ($Restore) {
            if (!$snap) { throw "Checkpoint absent. Recover from the exported VM in $folder/export using Hyper-V Manager." }
            Restore-VMSnapshot -VMSnapshot $snap -Confirm:$false
            & "$hostRoot/Start-Guest.ps1" -VMId $vm.Id
            Write-Host "Restored $label. Run ./hyperv/Connect-Guest.ps1 -Name $Name -Action Status to check services."
            return
        }
        $expected=[IO.Path]::GetFullPath("$hostRoot/updates/$BackupId")
        if ((Resolve-Path -LiteralPath $folder).Path -ne $expected) { throw 'Unexpected backup path.' }
        foreach ($item in @((Get-Item "$hostRoot/updates"),(Get-Item $folder)) + @(Get-ChildItem -LiteralPath $folder -Force -Recurse)) {
            if ($item.Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)) { throw "Refusing linked backup path: $($item.FullName)" }
        }
        if ($snap) { Remove-VMSnapshot -VMSnapshot $snap -Confirm:$false }
        Remove-Item -LiteralPath $expected -Recurse -Force
        Write-Host "Cleared upgrade backup $BackupId."
        return
    }
    if ($vm.State -ne 'Running' -or $vm.CheckpointType -ne 'ProductionOnly') { throw 'Expected a running VM with production-only checkpoints.' }
    $old=Invoke-GuestUpdate @('status') | ConvertFrom-Json
    # Reject backwards/unrelated version switches. Restore handles rollback.
    $compare=Invoke-RestMethod "https://api.github.com/repos/multica-ai/multica/compare/$($old.commit)...$($next.commit)?per_page=1"
    if ($compare.status -notin 'ahead','identical') { throw 'Target is older or divergent. Choose a newer release.' }
    $pins=@($next.commit,$next.backend,$next.frontend)
    Invoke-GuestUpdate (@('stage')+$pins)
    Invoke-GuestUpdate @('idle')
    $size=0L
    foreach ($disk in (Get-VMHardDiskDrive -VM $vm)) {
        $path=$disk.Path
        do { $vhd=Get-VHD -Path $path; $size+=$vhd.FileSize; $path=$vhd.ParentPath } while ($path)
        if ([IO.DriveInfo]::new([IO.Path]::GetPathRoot($disk.Path)).AvailableFreeSpace -lt 20GB) { throw 'Free 20 GiB on the checkpoint drive.' }
    }
    if ([IO.DriveInfo]::new([IO.Path]::GetPathRoot($folder)).AvailableFreeSpace -lt ($size+20GB)) { throw 'Insufficient host space for the private VM export and 20 GiB reserve.' }
    $null=New-Item -ItemType Directory -Path $folder -Force
    icacls $folder /inheritance:r /grant:r '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' | Out-Null
    $record=[ordered]@{id="$BackupId";vm="$($vm.Id)";previous=$old;target=$next;phase='preparing';snapshot=$null}
    $record | ConvertTo-Json | Set-Content $receipt
    Show-Backup
    $snap=Checkpoint-VM -VM $vm -SnapshotName $label -Passthru
    $record.snapshot="$($snap.Id)"; $record.phase='checkpoint-created'
    $record | ConvertTo-Json | Set-Content $receipt
    $null=New-Item -ItemType Directory -Path "$folder/export"
    Export-VMSnapshot -VMSnapshot $snap -Path "$folder/export"
    if (!(Get-ChildItem -LiteralPath "$folder/export" -Recurse -File -Filter '*.vmcx') -or
        !(Get-ChildItem -LiteralPath "$folder/export" -Recurse -File -Filter '*.vhdx')) {
        throw 'VM export is missing its configuration or virtual disk. Upgrade stopped before migration.'
    }
    $record.phase='backed-up'; $record | ConvertTo-Json | Set-Content $receipt
    if ($PreparedBackupId) { $PreparedBackupId.Value=$BackupId }
    Invoke-GuestUpdate (@('activate')+$pins+@("$BackupId"))
    $record.phase='verified'; $record | ConvertTo-Json | Set-Content $receipt
    Write-Host "Updated to $($next.tag). Dashboard, team and all three runtime registrations passed."
    Show-Backup
} catch {
    if ($Apply -and $receipt -and (Test-Path -LiteralPath $receipt)) {
        Write-Warning "Update stopped. Last recorded phase: $((Get-Content $receipt -Raw | ConvertFrom-Json).phase)"
        Show-Backup
    }
    throw
} finally { $lock.Dispose() }

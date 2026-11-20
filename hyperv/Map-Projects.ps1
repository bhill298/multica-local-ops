# Runs as the interactive Windows user, independently of the dashboard tunnel.
param([string]$Name='Multica-Ubuntu',[string]$Directory="$env:LOCALAPPDATA/MulticaVM/media")
$ErrorActionPreference='Stop'
if ($Name -notmatch '^[A-Za-z0-9-]{1,50}$') { throw 'Invalid VM name.' }
$vm=Get-Content "$env:ProgramFiles/MulticaVM/$Name/vm.json" -Raw | ConvertFrom-Json
if ($vm.phase -ne 'installed' -or !$vm.address) { throw 'Waiting for guest address discovery.' }
$address=[ipaddress]::Parse($vm.address).IPAddressToString
$share="\\$address\MulticaProjects"
$profileDir=Split-Path ([IO.Path]::GetFullPath($Directory))
$record=Join-Path $profileDir "$Name-project-drive.json"
$previous=if (Test-Path $record) { Get-Content $record -Raw | ConvertFrom-Json }
$all=@(Get-SmbMapping)
$current=$all | Where-Object { $_.RemotePath -eq $share -and $_.LocalPath } | Select-Object -First 1
if ($current -and (Test-Path -LiteralPath ($current.LocalPath+'\exchange'))) {
    @{local=$current.LocalPath;remote=$share} | ConvertTo-Json | Set-Content $record
    Write-Output "$($current.LocalPath) $share"
    return
}
$local=$current.LocalPath
if (!$local -and $previous.local -match '^[D-Z]:$') {
    $old=$all | Where-Object LocalPath -eq $previous.local | Select-Object -First 1
    if (($old -and $old.RemotePath -eq $previous.remote) -or
        (!$old -and !(Get-PSDrive $previous.local.Substring(0,1) -ErrorAction SilentlyContinue))) { $local=$previous.local }
}
if (!$local) {
    $letter=90..68 | ForEach-Object { [string][char]$_ } |
        Where-Object { ($_+':') -notin $all.LocalPath -and !(Get-PSDrive $_ -ErrorAction SilentlyContinue) } | Select-Object -First 1
    if (!$letter) { throw 'No free project drive letter.' }
    $local=$letter+':'
}
$key=Join-Path $profileDir keys/operator
$known=Join-Path $profileDir known_hosts
$secret=& "$env:SystemRoot/System32/OpenSSH/ssh.exe" -i $key -o BatchMode=yes -o IdentitiesOnly=yes -o ConnectTimeout=6 -o StrictHostKeyChecking=yes -o "HostKeyAlias=$Name" -o "UserKnownHostsFile=$known" "multicaops@$address" 'sudo cat /var/lib/multica-local/share-password'
if ($LASTEXITCODE -or !$secret) { throw 'Guest share credential is unavailable.' }
$credential=[pscredential]::new('multicafiles',(ConvertTo-SecureString $secret -AsPlainText -Force))
$secret=$null
$stale=Get-SmbMapping | Where-Object LocalPath -eq $local | Select-Object -First 1
if ($stale) {
    if ($stale.RemotePath -ne $share -and $stale.RemotePath -ne $previous.remote) { throw 'Drive was reassigned. Retry to select a free letter.' }
    Remove-SmbMapping -InputObject $stale -UpdateProfile -Force
}
New-SmbMapping -LocalPath $local -RemotePath $share -Credential $credential -RequirePrivacy $true -Persistent $false | Out-Null
if (!(Test-Path -LiteralPath ($local+'\exchange'))) { throw 'Exchange folder is unavailable after mapping.' }
@{local=$local;remote=$share} | ConvertTo-Json | Set-Content $record
Write-Output "$local $share"

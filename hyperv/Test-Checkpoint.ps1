#Requires -Version 7.3
#Requires -RunAsAdministrator
[CmdletBinding()]
param([string]$Name='Multica-Ubuntu',[string]$Directory="$env:LOCALAPPDATA/MulticaVM/media",
      [Parameter(Mandatory)][switch]$DisposablePilot)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$true
if ($Name -notmatch '^[A-Za-z0-9-]{1,50}$' -or !$DisposablePilot) { throw 'Use a disposable deployment for this restore test.' }
$root="$env:ProgramFiles/MulticaVM/$Name"
$state=Get-Content "$root/vm.json" -Raw | ConvertFrom-Json
$vm=Get-VM -Id $state.id
$keyRoot=Split-Path ([IO.Path]::GetFullPath($Directory))
$opts=@('-o','BatchMode=yes','-o','ConnectTimeout=5','-o',"HostKeyAlias=$Name",'-o','StrictHostKeyChecking=yes','-o',"UserKnownHostsFile=$keyRoot/known_hosts",'-i',"$keyRoot/keys/operator","multicaops@$($state.address)")
$tag=[guid]::NewGuid().ToString('N')
$flag="/var/tmp/multica-restore-$tag"
$sql='sudo docker exec multica-vm-postgres-1 psql -v ON_ERROR_STOP=1 -U multica -d multica -Atc'
# The caller must run this before daily work starts. Unique table and marker.
$table="pilot_restore_$tag"
ssh @opts "set -e; printf before > $flag; $sql 'CREATE TABLE $table (n int); INSERT INTO $table VALUES (1)'; sync"
$snapshot=Checkpoint-VM -VM $vm -SnapshotName "Multica restore test $tag" -Passthru
ssh @opts "set -e; printf after > $flag; $sql 'INSERT INTO $table VALUES (2)'; sync"
Restore-VMSnapshot -VMSnapshot $snapshot -Confirm:$false
if ((Get-VM -Id $vm.Id).State -eq 'Off') { Start-VM -VM $vm }
$limit=[datetime]::UtcNow.AddMinutes(6)
do {
    try {
        $proof=ssh @opts "cat $flag; echo; $sql 'SELECT count(*) FROM $table'; curl -fsS -o /dev/null -w '%{http_code}' http://127.0.0.1:43130"
        if (($proof -join ',') -eq 'before,1,200') { break }
    } catch { }
    Start-Sleep 4
} while ([datetime]::UtcNow -lt $limit)
if (($proof -join ',') -ne 'before,1,200') { throw "Restore verification failed. Checkpoint retained: $($snapshot.Id)" }
ssh @opts "$sql 'DROP TABLE $table'; rm -f $flag"
Remove-VMSnapshot -VMSnapshot $snapshot -ErrorAction Stop
@{at=[datetime]::UtcNow.ToString('o');vm=$vm.Id.ToString();checkpoint=$snapshot.Id.ToString();file='before';rows=1;ui=200} | ConvertTo-Json | Set-Content "$root/restore-result.json"

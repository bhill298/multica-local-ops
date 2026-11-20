#Requires -RunAsAdministrator
param([string]$Name='Multica-Ubuntu',[Parameter(Mandatory)][switch]$DisposablePilot)
$ErrorActionPreference='Stop'
if (!$DisposablePilot -or $Name -notmatch '^[A-Za-z0-9-]{1,50}$') { throw 'Use a disposable pilot.' }
$root="$env:ProgramFiles/MulticaVM/$Name"
Start-Transcript -Path "$root/rotation-test.log" -Force | Out-Null
$vm=Get-VM -Id (Get-Content "$root/vm.json" -Raw | ConvertFrom-Json).id
$prefix="MulticaManaged-$($vm.Id)-"
$task="$Name managed checkpoints"
$unmanaged=Checkpoint-VM -VM $vm -SnapshotName ('Manual retention witness '+[guid]::NewGuid()) -Passthru
try {
    for ($i=1;$i -le 5;$i++) {
        $before=@(Get-VMSnapshot -VM $vm | Where-Object Name -like "$prefix*").Id
        Start-ScheduledTask -TaskName $task
        $deadline=[datetime]::UtcNow.AddMinutes(4)
        do {
            Start-Sleep 2
            $after=@(Get-VMSnapshot -VM $vm | Where-Object Name -like "$prefix*")
            if (($after | Where-Object { $_.Id -notin $before }) -and (Get-ScheduledTask -TaskName $task).State -ne 'Running') { break }
        } while ([datetime]::UtcNow -lt $deadline)
        if (!($after | Where-Object { $_.Id -notin $before }) -or (Get-ScheduledTaskInfo -TaskName $task).LastTaskResult -ne 0) { throw "Scheduled checkpoint attempt $i failed." }
    }
    if ($after.Count -ne 4 -or !(Get-VMSnapshot -VM $vm | Where-Object Id -eq $unmanaged.Id)) { throw 'Retention invariant failed.' }
    @{at=[datetime]::UtcNow.ToString('o');runs=5;retained=4;manualPreserved=$true} | ConvertTo-Json | Set-Content "$root/rotation-result.json"
} finally {
    Remove-VMSnapshot -VMSnapshot $unmanaged
}

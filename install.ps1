param([Parameter(Mandatory)][string]$CandidateRoot)
$ErrorActionPreference='Stop'
$CandidateRoot=(Resolve-Path -LiteralPath $CandidateRoot).Path
$state=Join-Path $env:USERPROFILE '.multica/local-ops'
$bin=Join-Path $env:USERPROFILE '.multica/stock-runtime/bin'
New-Item -ItemType Directory -Force $state,$bin | Out-Null
foreach($name in @('multica.exe','supervisor.exe')){
 Copy-Item -LiteralPath (Join-Path $CandidateRoot "bin/$name") -Destination (Join-Path $bin $name) -Force
}
$candidate=Get-Content -LiteralPath (Join-Path $CandidateRoot 'supervisor-config.json') -Raw | ConvertFrom-Json
$candidate.cli=Join-Path $bin 'multica.exe'
$candidate.log_dir=Join-Path $state 'logs'
$config=Join-Path $state 'config.json'
$candidate | ConvertTo-Json | Set-Content -LiteralPath $config
$action=New-ScheduledTaskAction -Execute (Join-Path $bin 'supervisor.exe') -Argument ('"'+$config+'"')
$login=New-ScheduledTaskTrigger -AtLogOn -User ([Security.Principal.WindowsIdentity]::GetCurrent().Name)
$repeat=New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1)
$settings=New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 2) -StartWhenAvailable
Register-ScheduledTask -TaskName 'Multica Local Supervisor' -Action $action -Trigger @($login,$repeat) -Settings $settings -Description 'User-level stock Multica recovery with a hidden inherited console; no approval broker.' -Force | Out-Null
Get-ScheduledTask -TaskName 'Multica Local Supervisor' | Select-Object TaskName,State

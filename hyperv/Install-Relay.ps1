param([string]$Name='Multica-Ubuntu',[string]$Directory="$env:LOCALAPPDATA/MulticaVM/media")
$ErrorActionPreference='Stop'
if ($Name -notmatch '^[A-Za-z0-9-]{1,50}$') { throw 'Invalid VM name.' }
$profileDir=Split-Path ([IO.Path]::GetFullPath($Directory))
$dir=Join-Path $profileDir relay
$null=New-Item -ItemType Directory -Force -Path $dir
$relay=Join-Path $dir UI-Relay.ps1
Copy-Item "$PSScriptRoot/UI-Relay.ps1" $relay -Force
$config=Join-Path $dir relay.json
@{name=$Name;state="$env:ProgramFiles/MulticaVM/$Name/vm.json";key="$profileDir/keys/operator";known="$profileDir/known_hosts"} | ConvertTo-Json | Set-Content $config
$cmd='powershell.exe -NoLogo -NoProfile -NonInteractive -File "{0}" -Config "{1}"' -f $relay,$config
$vbs=Join-Path $dir relay.vbs
('WScript.Quit CreateObject("WScript.Shell").Run("{0}", 0, True)' -f $cmd.Replace('"','""')) | Set-Content $vbs -Encoding Unicode
$taskName="$Name dashboard relay"
$user=[Security.Principal.WindowsIdentity]::GetCurrent().Name
$action=New-ScheduledTaskAction -Execute "$env:SystemRoot/System32/wscript.exe" -Argument ('//B //Nologo "{0}"' -f $vbs)
$principal=New-ScheduledTaskPrincipal -UserId $user -RunLevel Limited -LogonType Interactive
$trigger=New-ScheduledTaskTrigger -AtLogon -User $user
$settings=New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Principal $principal -Settings $settings -Force | Out-Null
Start-ScheduledTask -TaskName $taskName

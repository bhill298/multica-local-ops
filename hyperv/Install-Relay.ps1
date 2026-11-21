param([string]$Name='Multica-Ubuntu',[string]$Directory="$env:LOCALAPPDATA/MulticaVM/media",[switch]$SkipProjectDrive)
$ErrorActionPreference='Stop'
if ($Name -notmatch '^[A-Za-z0-9-]{1,50}$') { throw 'Invalid VM name.' }
$ports=& "$PSScriptRoot/Get-InstallPorts.ps1" -Name $Name -Directory $Directory
$profileDir=Split-Path ([IO.Path]::GetFullPath($Directory))
$dir=Join-Path $profileDir relay
$null=New-Item -ItemType Directory -Force -Path $dir
$relay=Join-Path $dir UI-Relay.ps1
Copy-Item "$PSScriptRoot/UI-Relay.ps1" $relay -Force
$config=Join-Path $dir relay.json
@{name=$Name;state="$env:ProgramFiles/MulticaVM/$Name/vm.json";key="$profileDir/keys/operator";known="$profileDir/known_hosts";ports=$ports} | ConvertTo-Json | Set-Content $config
$cmd='powershell.exe -NoLogo -NoProfile -NonInteractive -File "{0}" -Config "{1}"' -f $relay,$config
$vbs=Join-Path $dir relay.vbs
('WScript.Quit CreateObject("WScript.Shell").Run("{0}", 0, True)' -f $cmd.Replace('"','""')) | Set-Content $vbs -Encoding Unicode
$taskName="$Name dashboard relay"
$user=[Security.Principal.WindowsIdentity]::GetCurrent().Name
$action=New-ScheduledTaskAction -Execute "$env:SystemRoot/System32/wscript.exe" -Argument ('//B //Nologo "{0}"' -f $vbs)
$principal=New-ScheduledTaskPrincipal -UserId $user -RunLevel Limited -LogonType Interactive
$trigger=New-ScheduledTaskTrigger -AtLogon -User $user
$settings=New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
if ((Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue).State -eq 'Running') {
    Stop-ScheduledTask -TaskName $taskName
}
# Task Scheduler can stop wscript while leaving its OpenSSH child bound.
$client="$env:SystemRoot/System32/OpenSSH/ssh.exe"
foreach ($child in Get-CimInstance Win32_Process -Filter "Name='ssh.exe'") {
    $cmdline=$child.CommandLine
    if ($child.ExecutablePath -eq ([IO.Path]::GetFullPath($client)) -and $cmdline -and
        $cmdline.Contains("HostKeyAlias=$Name ") -and $cmdline.Contains("$profileDir/keys/operator") -and
        $cmdline.Contains(' -NT ') -and $cmdline -match ' -L 127\.0\.0\.1:\d+:127\.0\.0\.1:4313[02]( |$)' -and
        $cmdline -match ' multicaops@[0-9.]+$') {
        Stop-Process -Id $child.ProcessId -ErrorAction SilentlyContinue
    }
}
Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Principal $principal -Settings $settings -Force | Out-Null
Start-ScheduledTask -TaskName $taskName
$handler=[Net.Http.HttpClientHandler]::new()
$handler.AllowAutoRedirect=$false
$handler.UseProxy=$false
$http=[Net.Http.HttpClient]::new($handler)
$http.Timeout=[TimeSpan]::FromSeconds(3)
try {
    $deadline=[datetime]::UtcNow.AddSeconds(45)
    do {
        $ready=$true
        foreach ($route in @{user="http://localhost:$($ports.daily)/login";admin="http://127.0.0.1:$($ports.admin)/login"}.GetEnumerator()) {
            try {
                $response=$http.GetAsync("http://127.0.0.1:$($ports.home)/$($route.Key)").GetAwaiter().GetResult()
                try { $ready=$ready -and [int]$response.StatusCode -eq 302 -and $response.Headers.Location.AbsoluteUri -eq $route.Value }
                finally { $response.Dispose() }
            } catch { $ready=$false }
        }
        if ($ready) { break }
        Start-Sleep 2
    } while ([datetime]::UtcNow -lt $deadline)
    if (!$ready) { throw "Dashboard relay did not serve the configured links. Check the '$taskName' scheduled task and hyperv/dashboard-ports.json." }
} finally { $http.Dispose() }
$mapTask="$Name project drive"
if ($SkipProjectDrive) {
    if (Get-ScheduledTask -TaskName $mapTask -ErrorAction SilentlyContinue) { Disable-ScheduledTask -TaskName $mapTask | Out-Null }
    return
}
$mapper=Join-Path $dir Map-Projects.ps1
Copy-Item "$PSScriptRoot/Map-Projects.ps1" $mapper -Force
$cmd='powershell.exe -NoLogo -NoProfile -NonInteractive -File "{0}" -Name "{1}" -Directory "{2}"' -f $mapper,$Name,([IO.Path]::GetFullPath($Directory))
$vbs=Join-Path $dir projects.vbs
('WScript.Quit CreateObject("WScript.Shell").Run("{0}", 0, True)' -f $cmd.Replace('"','""')) | Set-Content $vbs -Encoding Unicode
$action=New-ScheduledTaskAction -Execute "$env:SystemRoot/System32/wscript.exe" -Argument ('//B //Nologo "{0}"' -f $vbs)
Register-ScheduledTask -TaskName $mapTask -Trigger $trigger -Action $action -Principal $principal -Settings $settings -Force | Out-Null

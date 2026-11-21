#Requires -Version 7.3
param([ValidatePattern('^[A-Za-z0-9-]{1,50}$')][string]$Name='Multica-Ubuntu',[string]$Directory="$env:LOCALAPPDATA/MulticaVM/media",
    [ValidateRange(1,65535)][int]$WebPort,[switch]$SkipProjectDrive)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$true
$Directory=[IO.Path]::GetFullPath($Directory)
$profileDir=Split-Path $Directory
$dir=Join-Path $profileDir portal
$root=Join-Path $env:ProgramFiles "MulticaVM/$Name"
$ports=& "$PSScriptRoot/Get-InstallPorts.ps1" -Name $Name -Directory $Directory
$prefix=if ($Name -eq 'Multica-Ubuntu') {'multica'} else {$Name.ToLowerInvariant()}
if (!$WebPort) {
    $WebPort=if (Test-Path "$root/portal/install.json"){(Get-Content "$root/portal/install.json" -Raw | ConvertFrom-Json).webPort}
        elseif ($Name -eq 'Multica-Ubuntu'){80}else{$ports.home}
}
if ($WebPort -in $ports.daily,$ports.admin) {throw 'WebPort overlaps a dashboard tunnel.'}
$exe=Join-Path $dir 'multica-portal.exe'
if ($WebPort -ne $ports.home) {
    $listeners=@(Get-NetTCPConnection -State Listen -LocalPort $WebPort -ErrorAction SilentlyContinue | Where-Object LocalAddress -in '0.0.0.0','127.0.0.1','::','::1')
    foreach ($l in $listeners) {
        if ((Get-Process -Id $l.OwningProcess).Path -ne $exe) {throw "Port $WebPort is occupied. Select a free -WebPort."}
    }
    if (!$listeners) {
        $probe=[Net.Sockets.TcpListener]::new([ipaddress]::Loopback,$WebPort)
        try {$probe.ExclusiveAddressUse=$true;$probe.Start()} finally {$probe.Stop()}
    }
}
$null=New-Item -ItemType Directory -Force -Path $dir
$who=[Security.Principal.WindowsIdentity]::GetCurrent()
icacls $dir /inheritance:r /grant:r ("*"+$who.User.Value+':(OI)(CI)F') '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' | Out-Null
$repo=Split-Path $PSScriptRoot
$build=Join-Path $dir 'multica-portal.new.exe'
if (Get-Command go.exe -ErrorAction SilentlyContinue) {
    go -C $repo build -trimpath -ldflags '-H=windowsgui' -o $build ./cmd/portal
} else {
    $out=(New-Item -ItemType Directory -Force -Path (Join-Path $dir build)).FullName
    docker run --rm --mount "type=bind,src=$repo/cmd/portal,dst=/src,readonly" --mount "type=bind,src=$out,dst=/out" -w /src -e GO111MODULE=off -e GOOS=windows -e GOARCH=amd64 -e CGO_ENABLED=0 golang:1.26.9-bookworm go build -trimpath -ldflags '-H=windowsgui' -o /out/multica-portal.new.exe .
    Move-Item -LiteralPath "$out/multica-portal.new.exe" -Destination $build -Force
    if (!(Get-ChildItem -LiteralPath $out -Force)){ Remove-Item -LiteralPath $out }
}
$pwsh=(Get-Process -Id $PID).Path
$standard=Join-Path $env:ProgramFiles 'PowerShell/7/pwsh.exe'
if (Test-Path -LiteralPath $standard) {
    if ([version](& $standard -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()') -ge [version]'7.3') { $pwsh=$standard }
}
$arg='-NoProfile -NonInteractive -File "{0}" -Name {1} -Directory "{2}" -Prefix {3} -WebPort {4}' -f "$PSScriptRoot/Install-PortalHost.ps1",$Name,$Directory,$prefix,$WebPort
$p=Start-Process $pwsh -Verb RunAs -WindowStyle Hidden -ArgumentList $arg -Wait -PassThru
if ($p.ExitCode) {throw 'Host setup failed. Check the VM identity and hosts file for conflicts.'}
$task="$Name management portal"
if (Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue) {
    Stop-ScheduledTask -TaskName $task
    foreach ($proc in Get-Process -Name multica-portal -ErrorAction SilentlyContinue) {
        if ($proc.Path -eq $exe){$proc.Kill();$proc.WaitForExit()}
    }
}
Move-Item -LiteralPath $build -Destination $exe -Force
$keyFile="$dir/operator.key"
if (!(Test-Path $keyFile)) {
    [IO.File]::WriteAllText($keyFile,[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32)).ToLowerInvariant())
}
$config=@{name=$Name;prefix=$prefix;home=$ports.home;daily=$ports.daily;admin=$ports.admin;port=$WebPort;directory=$Directory;script="$root/portal/Portal-Action.ps1";powerShell=$pwsh}
$config | ConvertTo-Json | Set-Content "$dir/portal.json"
$action=New-ScheduledTaskAction -Execute $exe -Argument ('"{0}"' -f "$dir/portal.json")
$trigger=New-ScheduledTaskTrigger -AtLogon -User $who.Name
$principal=New-ScheduledTaskPrincipal -UserId $who.Name -LogonType Interactive -RunLevel Limited
$settings=New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew -RestartCount 99 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $task -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
& "$PSScriptRoot/Install-Relay.ps1" -Name $Name -Directory $Directory -SkipProjectDrive:$SkipProjectDrive -Portal
$authority=$prefix+'.localhost'+$(if ($WebPort -ne 80){":$WebPort"})
$pair=Join-Path $dir open-management.html
$secret=(Get-Content -LiteralPath $keyFile -Raw).Trim()
[IO.File]::WriteAllText($pair,('<meta charset="utf-8"><meta name="referrer" content="no-referrer"><script>location.replace({0})</script>' -f (ConvertTo-Json "http://$authority/manage#$secret" -Compress)))
$shell=New-Object -ComObject WScript.Shell
$link=$shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Programs')) "$Name Management.lnk"))
$link.TargetPath="$env:SystemRoot/explorer.exe"
$link.Arguments='"'+$pair+'"'
$link.Description="Manage the local $Name installation"
$link.Save()
"Open http://$authority/ on Windows. Open '$Name Management' in Start to pair this browser."

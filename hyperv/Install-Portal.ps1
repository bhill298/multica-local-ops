#Requires -Version 7.3
param([ValidatePattern('^[A-Za-z0-9-]{1,50}$')][string]$Name='Multica-Ubuntu',[string]$Directory="$env:LOCALAPPDATA/MulticaVM/media",
    [ValidateRange(1,65535)][int]$WebPort,[ipaddress]$LanAddress,[switch]$SkipProjectDrive,[switch]$RequireManagementKey)
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
if (!$LanAddress) {
    $installed=if (Test-Path "$root/portal/install.json"){Get-Content "$root/portal/install.json" -Raw | ConvertFrom-Json}
    $LanAddress=if ($installed.lanAddress) {$installed.lanAddress} else {'127.0.0.1'}
}
$lan=& "$PSScriptRoot/Get-PortalLanBinding.ps1" -Address $LanAddress
if ($lan) {
    $listeners=@(Get-NetTCPConnection -State Listen -LocalPort $WebPort -ErrorAction SilentlyContinue |
        Where-Object LocalAddress -in $LanAddress.IPAddressToString,'0.0.0.0','::')
    foreach ($l in $listeners) {
        if ((Get-Process -Id $l.OwningProcess).Path -ne $exe){throw "LAN port $WebPort is occupied. Select another -WebPort."}
    }
    if (!$listeners) {
        $probe=[Net.Sockets.TcpListener]::new($LanAddress,$WebPort)
        try {$probe.ExclusiveAddressUse=$true;$probe.Start()} finally {$probe.Stop()}
    }
}
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
$configPath=Join-Path $dir portal.json
$previous=if (Test-Path -LiteralPath $configPath){Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json}
if (!$PSBoundParameters.ContainsKey('RequireManagementKey') -and $previous) {
    # Configurations predating managementAuth were always keyed.
    if ($previous.managementAuth -notin $null,'key','local'){throw 'Unknown installed portal authentication mode.'}
    $RequireManagementKey=$previous.managementAuth -ne 'local'
}
$mode=if ($RequireManagementKey){'key'}else{'local'}
$keyFile=Join-Path $dir operator.key
$secret=''
if ($RequireManagementKey) {
    if (Test-Path -LiteralPath $keyFile) {$secret=[IO.File]::ReadAllText($keyFile).Trim()}
    if (!$secret) {$secret=[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32)).ToLowerInvariant()}
    if ($secret -cnotmatch '^[0-9a-f]{64}$'){throw 'The existing operator key is invalid.'}
}
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
$arg='-NoProfile -NonInteractive -File "{0}" -Name {1} -Directory "{2}" -Prefix {3} -WebPort {4} -LanAddress {5}' -f "$PSScriptRoot/Install-PortalHost.ps1",$Name,$Directory,$prefix,$WebPort,$LanAddress
$p=Start-Process $pwsh -Verb RunAs -WindowStyle Hidden -ArgumentList $arg -Wait -PassThru
if ($p.ExitCode) {throw 'Host setup failed. Check the VM identity, hosts file and any LAN firewall policy.'}
$task="$Name management portal"
if (Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue) {
    Stop-ScheduledTask -TaskName $task
    foreach ($proc in Get-Process -Name multica-portal -ErrorAction SilentlyContinue) {
        if ($proc.Path -eq $exe){$proc.Kill();$proc.WaitForExit()}
    }
}
Move-Item -LiteralPath $build -Destination $exe -Force
[IO.File]::WriteAllText($keyFile,$secret)
$config=@{name=$Name;prefix=$prefix;home=$ports.home;daily=$ports.daily;admin=$ports.admin;port=$WebPort;directory=$Directory;script="$root/portal/Portal-Action.ps1";powerShell=$pwsh;managementAuth=$mode}
if ($lan) { $config.lanBinding=$lan.Binding }
$config | ConvertTo-Json | Set-Content -LiteralPath $configPath
$pair=Join-Path $dir open-management.html
if (!$RequireManagementKey) {
    & "$PSScriptRoot/Remove-PortalShortcut.ps1" -Name $Name -ProfileDir $profileDir
    if (Test-Path -LiteralPath $pair){Remove-Item -LiteralPath $pair}
}
$action=New-ScheduledTaskAction -Execute $exe -Argument ('"{0}"' -f "$dir/portal.json")
$trigger=New-ScheduledTaskTrigger -AtLogon -User $who.Name
$principal=New-ScheduledTaskPrincipal -UserId $who.Name -LogonType Interactive -RunLevel Limited
$settings=New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew -RestartCount 99 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $task -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
& "$PSScriptRoot/Install-Relay.ps1" -Name $Name -Directory $Directory -SkipProjectDrive:$SkipProjectDrive -Portal
$authority=$prefix+'.localhost'+$(if ($WebPort -ne 80){":$WebPort"})
if ($lan) {
    $suffix=if ($WebPort -ne 80){":$WebPort"}else{''}
    $expected="http://admin.$prefix.home.arpa$suffix/login"
    # Check the LAN socket directly. Client-side DNS may not be configured yet.
    $http=[Net.Http.HttpClient]::new([Net.Http.HttpClientHandler]@{UseProxy=$false;AllowAutoRedirect=$false})
    $http.Timeout=[TimeSpan]::FromSeconds(2)
    $http.DefaultRequestHeaders.Host="$prefix.home.arpa$suffix"
    try {
        $deadline=[datetime]::UtcNow.AddSeconds(15)
        do {
            try {
                $answer=$http.GetAsync("http://${LanAddress}:$WebPort/admin").GetAwaiter().GetResult()
                try {$ready=[int]$answer.StatusCode -eq 302 -and $answer.Headers.Location.AbsoluteUri -eq $expected}
                finally {$answer.Dispose()}
            } catch {$ready=$false}
            if (!$ready) {Start-Sleep -Milliseconds 500}
        } until ($ready -or [datetime]::UtcNow -ge $deadline)
        if (!$ready){throw "Local portal is installed, but the LAN listener on ${LanAddress}:$WebPort did not return the expected redirect. Verify the address and port, then rerun."}
    } finally {$http.Dispose()}
    "In LAN DNS point $prefix.home.arpa, user.$prefix.home.arpa and admin.$prefix.home.arpa to $LanAddress."
    "Open http://$prefix.home.arpa$suffix/ on a LAN client."
}
if (!$RequireManagementKey) { "Open http://$authority/manage on Windows."; return }
[IO.File]::WriteAllText($pair,('<meta charset="utf-8"><meta name="referrer" content="no-referrer"><script>location.replace({0})</script>' -f (ConvertTo-Json "http://$authority/manage#$secret" -Compress)))
$shell=New-Object -ComObject WScript.Shell
$link=$shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Programs')) "$Name Management.lnk"))
$link.TargetPath="$env:SystemRoot/explorer.exe"
$link.Arguments='"'+$pair+'"'
$link.Description="Manage the local $Name installation"
$link.Save()
"Open http://$authority/ on Windows. Open '$Name Management' in Start to pair this browser."

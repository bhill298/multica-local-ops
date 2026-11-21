#Requires -Version 7.2
param([switch]$Docker)
$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot
. (Join-Path $repo 'scripts/common.ps1')
function Assert($Condition,[string]$Message) { if(-not $Condition){throw $Message} }
$temporary=Join-Path ([IO.Path]::GetTempPath()) ('multica-ops-tests-'+[Guid]::NewGuid())
New-Item -ItemType Directory -Path $temporary | Out-Null
$checks=0
try {
    foreach($file in Get-ChildItem -LiteralPath $repo -Recurse -Filter '*.ps1') {
        $parseErrors=$null
        [void][Management.Automation.Language.Parser]::ParseFile($file.FullName,[ref]$null,[ref]$parseErrors)
        Assert (-not $parseErrors) "Parse error: $($file.Name)"
    }
    $checks++
    $good=Read-Settings (Join-Path $repo 'config/settings.json')
    foreach($change in @(
        @{profile='../other'}, @{frontend_port=80}, @{backend_port=$good.frontend_port},
        @{upstream_url='https://example.test/other.git'}, @{upstream_commit='main'},
        @{codex_args='--dangerously-bypass-approvals-and-sandbox'}
    )) {
        $bad=Get-Content -LiteralPath (Join-Path $repo 'config/settings.json') -Raw | ConvertFrom-Json -AsHashtable
        foreach($key in $change.Keys){$bad[$key]=$change[$key]}
        $file=Join-Path $temporary 'bad.json';Write-JsonFile $file $bad
        $rejected=$false
        try{$null=Read-Settings $file}catch{$rejected=$true}
        Assert $rejected 'Accepted an unsafe or ambiguous setting'
    }
    $checks++
    $pwsh=(Get-Process -Id $PID).Path
    $result=Invoke-Hidden $pwsh @('-NoProfile','-NonInteractive','-Command',"[Console]::Out.Write('out');[Console]::Error.Write('err')")
    Assert ($result.Stdout -eq 'out' -and $result.Stderr -eq 'err') 'Lost redirected output'
    $checks++
    $message=''
    try{$null=Invoke-Hidden $pwsh @('-NoProfile','-NonInteractive','-Command',"[Console]::Error.Write('sensitive-fixture');exit 7")}catch{$message=$_.Exception.Message}
    Assert ($message -match 'exit 7' -and $message -notmatch 'sensitive-fixture') 'Failure exposed raw diagnostics or lost exit code'
    $checks++
    $inputResult=Invoke-Hidden $pwsh @('-NoProfile','-NonInteractive','-Command','[Console]::Out.Write([Console]::In.ReadToEnd())') -InputText "a value with spaces`n"
    Assert ($inputResult.Stdout -eq "a value with spaces`n") 'Stdin login channel changed input'
    $checks++
    $binary=Join-Path $temporary 'binary.dat'
    $null=Invoke-Hidden $pwsh @('-NoProfile','-NonInteractive','-Command','[Console]::OpenStandardOutput().Write([byte[]](0,128,255))') -OutputFile $binary
    Assert ([Convert]::ToHexString([IO.File]::ReadAllBytes($binary)) -eq '0080FF') 'Backup stream corrupted binary data'
    $checks++
    Protect-LocalFile $binary
    Assert ((Get-Acl -LiteralPath $binary).AreAccessRulesProtected) 'Private file still inherits broad permissions'
    $privateRead=Invoke-Hidden $pwsh @('-NoProfile','-NonInteractive','-Command',"[Console]::Out.Write([IO.File]::ReadAllBytes('$binary').Length)")
    Assert ($privateRead.Stdout -eq '3') 'Ordinary child cannot read the private runtime file'
    $checks++
    $timedOut=$false
    try{$null=Invoke-Hidden $pwsh @('-NoProfile','-NonInteractive','-Command','Start-Sleep -Seconds 30') -TimeoutSeconds 1}catch{$timedOut=$_.Exception.Message -match 'timed out'}
    Assert $timedOut 'Hung child did not time out'
    $checks++
    if($Docker){
        $values=@{POSTGRES_IMAGE=$good.images.postgres;BACKEND_IMAGE=$good.images.backend;FRONTEND_IMAGE=$good.images.frontend;POSTGRES_PASSWORD='fixture-only';JWT_SECRET='fixture-only';FRONTEND_PORT='43130';BACKEND_PORT='43131';APP_ENV='development';MULTICA_DEV_VERIFICATION_CODE='888888';AUTH_TOKEN_TTL='87600h';LOGIN_EMAIL='local@example.test';PG_VOLUME='fixture_pg';UPLOADS_VOLUME='fixture_uploads'}
        ($values.GetEnumerator()|ForEach-Object{"$($_.Key)=$($_.Value)"})|Set-Content -LiteralPath (Join-Path $temporary '.env')
        Copy-Item -LiteralPath (Join-Path $repo 'compose.yml') -Destination (Join-Path $temporary 'compose.yml')
        $original=[Environment]::GetEnvironmentVariable('APP_ENV')
        try{
            $env:APP_ENV='production'
            $result=Invoke-Compose @{Root=$temporary;Project='multica-config-test'} @('config','--format','json')
            $plan=$result.Stdout|ConvertFrom-Json -AsHashtable
            Assert ($plan.services.backend.environment.APP_ENV -eq 'development') 'Ambient environment overrode reviewed auth configuration'
            Assert ($env:APP_ENV -eq 'production') 'Caller environment was not restored'
            Assert ($plan.services.backend.environment.AUTH_TOKEN_TTL -eq '87600h') 'TTL not forwarded into container'
            Assert ($plan.services.backend.ports[0].host_ip -eq '127.0.0.1' -and $plan.services.frontend.ports[0].host_ip -eq '127.0.0.1') 'Public port binding'
            Assert ($plan.volumes.pgdata.external -and $plan.volumes.backend_uploads.external) 'Data volumes could be removed by compose down'
        }finally{[Environment]::SetEnvironmentVariable('APP_ENV',$original)}
        $volumeProject='multica-ops-test-'+[Guid]::NewGuid().ToString('N')
        $volumeName=$volumeProject+'_pgdata'
        Assert-NewVolumesUnused $volumeProject
        $null=Invoke-Hidden docker @('volume','create',$volumeName)
        try {
            $refused=$false
            try{Assert-NewVolumesUnused $volumeProject}catch{$refused=$true}
            Assert $refused 'Existing database volume was silently reused without its secrets'
        }finally{$null=Invoke-Hidden docker @('volume','rm',$volumeName)}
        $checks++
    }
    # Exercise the real selection prompt without renewing a provider session.
    Copy-Item "$repo/hyperv/Connect-Providers.ps1" $temporary
    @'
param($Name,$Directory,$Action,$Provider)
if ($Name -ne 'Login-Test' -or $Directory -ne $PSScriptRoot -or $Action -ne 'Auth') { throw 'Incorrect login target' }
Write-Output $Provider
'@ | Set-Content "$temporary/Connect-Guest.ps1"
    foreach ($case in @(
        @{answers=@('');want=''}, @{answers=@('none');want=''},
        @{answers=@('codex');want='codex'}, @{answers=@('wrong','agy, CODEX, agy');want='agy,codex'},
        @{answers=@('all');want='codex,claude,agy'}
    )) {
        $seen = & {
            $responses=[Collections.Generic.Queue[string]]::new([string[]]$case.answers)
            function Read-Host { $responses.Dequeue() }
            & "$temporary/Connect-Providers.ps1" -Name Login-Test -Directory $temporary
        }
        Assert (($seen -join ',') -eq $case.want) 'Unexpected provider sign-in selection'
    }
    $checks++
    Copy-Item "$repo/install.ps1" $temporary
    @'
param([string]$AdminProvider,[string]$AdminModel,[switch]$SkipProviderLogin)
"$AdminProvider/$AdminModel/$SkipProviderLogin"
'@ | Set-Content "$temporary/install-vm.ps1"
    $forwarded=& "$temporary/install.ps1" -HyperV -AdminProvider agy -AdminModel gemini-3.8-flash-low -SkipProviderLogin
    Assert ($forwarded -eq 'agy/gemini-3.8-flash-low/True') 'Hyper-V admin selection was not forwarded'
    $checks++
    Write-Host "$checks installer test groups passed."
}finally{
    $resolved=[IO.Path]::GetFullPath($temporary)
    $expected=[IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    if(-not $resolved.StartsWith($expected,[StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($resolved) -notlike 'multica-ops-tests-*'){throw 'Refusing unexpected cleanup target'}
    Remove-Item -LiteralPath $resolved -Recurse -Force
}

#Requires -Version 7.2
[CmdletBinding()]
param(
    [switch]$HyperV,
    [switch]$SkipProviderLogin,
    [string]$SettingsFile = (Join-Path $PSScriptRoot 'config/settings.json'),
    [string]$Root = (Join-Path $env:USERPROFILE '.multica/local-ops'),
    [string]$BinRoot = (Join-Path $env:USERPROFILE '.multica/stock-runtime/bin'),
    [string]$WorkspacesRoot = (Join-Path $env:USERPROFILE '.multica/workspaces-local'),
    [switch]$AdoptExisting,
    [string]$AdoptComposeProject,
    [switch]$RenewLocalAuth
)
if ($HyperV) {
    if ($PSBoundParameters.Keys | Where-Object { $_ -notin 'HyperV','SkipProviderLogin' }) { throw 'For VM-specific options run install-vm.ps1 directly.' }
    & "$PSScriptRoot/install-vm.ps1" -SkipProviderLogin:$SkipProviderLogin
    return
}
if ($SkipProviderLogin) { throw 'SkipProviderLogin applies to the Hyper-V installer.' }
. (Join-Path $PSScriptRoot 'scripts/common.ps1')
. (Join-Path $PSScriptRoot 'scripts/team.ps1')
if (-not $IsWindows) { throw 'This installer requires native Windows and PowerShell 7.' }
$settings = Read-Settings $SettingsFile
foreach ($name in @('git','go','docker','codex')) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { throw "Install $name and make it available on PATH, then rerun. See README.md." }
}
$dockerType = Invoke-Hidden docker @('info','--format','{{.OSType}}')
if ($dockerType.Stdout.Trim() -ne 'linux') { throw 'Start Docker Desktop with Linux containers.' }
$null = Invoke-Hidden docker @('compose','version')
$Root = [IO.Path]::GetFullPath($Root)
$BinRoot = [IO.Path]::GetFullPath($BinRoot)
$WorkspacesRoot = [IO.Path]::GetFullPath($WorkspacesRoot)
foreach ($path in @($Root,$BinRoot,$WorkspacesRoot)) {
    if ($path.StartsWith($PSScriptRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or $path -eq $PSScriptRoot) { throw 'Keep runtime files outside this Git checkout.' }
}
New-Item -ItemType Directory -Force -Path $Root,$BinRoot,$WorkspacesRoot,(Join-Path $Root 'assets'),(Join-Path $Root 'build') | Out-Null
$statePath = Join-Path $Root 'install-state.json'
$previous = $null
if (Test-Path -LiteralPath $statePath) { $previous = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json -AsHashtable }
$profileExists = Test-Path -LiteralPath (Join-Path $env:USERPROFILE ('.multica/profiles/'+$settings.profile+'/config.json'))
$bootstrapPath = Join-Path $Root 'bootstrap.json'
$resumingFreshSetup = Test-Path -LiteralPath $bootstrapPath
if (-not $previous -and -not $resumingFreshSetup -and ((Test-Path -LiteralPath (Join-Path $Root 'config.json')) -or $profileExists)) {
    if (-not $AdoptExisting -or -not $AdoptComposeProject) { throw 'An existing installation/profile was found. Use the reviewed -AdoptExisting -AdoptComposeProject mode; no live settings were changed.' }
}
if (-not $previous -and -not $resumingFreshSetup -and -not $AdoptComposeProject) {
    foreach ($port in @($settings.frontend_port,$settings.backend_port)) {
        $listener=[Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$port)
        try { $listener.Start() } catch { throw "Local port $port is in use. Choose other ports or deliberately adopt the existing stack." } finally { $listener.Stop() }
    }
}
if ($AdoptComposeProject -and $AdoptComposeProject -notmatch '^[a-z0-9][a-z0-9_-]*$') { throw 'Invalid adopted Compose project' }
$project = $(if ($previous) { $previous.compose_project } elseif ($AdoptComposeProject) { $AdoptComposeProject } else { $settings.compose_project })
$context = @{Root=$Root; Settings=$settings; Cli=(Join-Path $BinRoot 'multica.exe'); Project=$project; NewWorkspace=$false; PreviouslyInstalled=($null -ne $previous)}

Write-Host 'Fetching the pinned upstream source.'
$source = Join-Path $Root 'upstream'
if (-not (Test-Path -LiteralPath (Join-Path $source '.git'))) {
    if ((Test-Path -LiteralPath $source) -and @(Get-ChildItem -LiteralPath $source -Force).Count) { throw 'Upstream target is not an empty directory or Git checkout.' }
    New-Item -ItemType Directory -Force -Path $source | Out-Null
    $null = Invoke-Hidden git @('init', $source)
    $null = Invoke-Hidden git @('-C',$source,'remote','add','origin',$settings.upstream_url)
}
$remote = Invoke-Hidden git @('-C',$source,'remote','get-url','origin')
if ($remote.Stdout.Trim() -ne $settings.upstream_url) { throw 'Existing source checkout has a different origin.' }
$dirty = Invoke-Hidden git @('-C',$source,'status','--porcelain')
if ($dirty.Stdout.Trim()) { throw 'Upstream checkout has local changes; preserve them before installing.' }
$head = Invoke-Hidden git @('-C',$source,'rev-parse','HEAD') -AllowFailure
if ($head.ExitCode -ne 0 -or $head.Stdout.Trim() -ne $settings.upstream_commit) {
    $null = Invoke-Hidden git @('-c','http.version=HTTP/1.1','-C',$source,'fetch','--depth','1','origin',$settings.upstream_commit) -Environment @{GIT_HTTP_LOW_SPEED_LIMIT='1000';GIT_HTTP_LOW_SPEED_TIME='60'} -TimeoutSeconds 600
    $null = Invoke-Hidden git @('-C',$source,'checkout','--detach',$settings.upstream_commit)
}
Write-Host 'Building the stock CLI and Windows supervisor.'
$build = Join-Path $Root 'build'
$null = Invoke-Hidden go @('build','-trimpath','-o',(Join-Path $build 'multica.exe'),'./cmd/multica') -WorkingDirectory (Join-Path $source 'server') -Environment @{GOTOOLCHAIN='auto'} -TimeoutSeconds 1200
$null = Invoke-Hidden go @('build','-trimpath','-ldflags=-H=windowsgui','-o',(Join-Path $build 'supervisor.exe'),'.') -WorkingDirectory $PSScriptRoot -TimeoutSeconds 300

# Every mutation of the live deployment happens after both builds succeed.
$oldTask = Get-ScheduledTask -TaskName $settings.task_name -ErrorAction SilentlyContinue
if ((Test-Path -LiteralPath $context.Cli) -and $profileExists) {
    $status = Invoke-Multica $context @('daemon','status') -Json
    if ($status['active_task_count'] -gt 0) { throw 'Multica has active work. Finish or deliberately stop it before rerunning install.' }
}
if ($oldTask) {
    Disable-ScheduledTask -TaskName $settings.task_name | Out-Null
    if ((Get-ScheduledTask -TaskName $settings.task_name).State -eq 'Running') { Stop-ScheduledTask -TaskName $settings.task_name }
}
$wasEnabled = $oldTask -and $oldTask.State -ne 'Disabled'
try {
    if (-not $previous -and -not $resumingFreshSetup -and -not $AdoptComposeProject) { Write-JsonFile $bootstrapPath @{profile=$settings.profile;created_at=[DateTimeOffset]::UtcNow.ToString('o')} }
    if ((Test-Path -LiteralPath $context.Cli) -and $profileExists) { Invoke-Multica $context @('daemon','stop') }
    $privateEnv = Join-Path $Root '.env'
    $values = @{}
    if (Test-Path -LiteralPath $privateEnv) {
        foreach ($line in Get-Content -LiteralPath $privateEnv) { if ($line -match '^([A-Z_]+)=(.*)$') { $values[$Matches[1]]=$Matches[2] } }
    } elseif ($AdoptComposeProject) {
        if (-not $AdoptExisting) { throw 'Adopting live containers also requires -AdoptExisting.' }
        $inspection = Invoke-Hidden docker @('inspect',($project+'-backend-1'),($project+'-postgres-1'))
        $containers = $inspection.Stdout | ConvertFrom-Json -AsHashtable
        $backend = $containers[0]; $postgres = $containers[1]
        $imageInfo=Invoke-Hidden docker @('image','inspect',$backend.Image,$postgres.Image)
        $imageMetadata=$imageInfo.Stdout | ConvertFrom-Json -AsHashtable
        if ($settings.images.backend -notin $imageMetadata[0].RepoDigests -or $settings.images.postgres -notin $imageMetadata[1].RepoDigests) { throw 'Adoption requires the reviewed backend/Postgres images. Do not upgrade an existing database implicitly.' }
        $backendEnv=@{}; foreach ($line in $backend.Config.Env) { $pair=$line.Split('=',2);$backendEnv[$pair[0]]=$pair[1] }
        $postgresEnv=@{}; foreach ($line in $postgres.Config.Env) { $pair=$line.Split('=',2);$postgresEnv[$pair[0]]=$pair[1] }
        if ($postgresEnv.POSTGRES_DB -ne 'multica' -or $postgresEnv.POSTGRES_USER -ne 'multica') { throw 'Adopted database must use the documented multica database/user.' }
        $values.JWT_SECRET=$backendEnv.JWT_SECRET
        $values.POSTGRES_PASSWORD=$postgresEnv.POSTGRES_PASSWORD
        $values.PG_VOLUME=($postgres.Mounts | Where-Object Destination -EQ '/var/lib/postgresql/data').Name
        $values.UPLOADS_VOLUME=($backend.Mounts | Where-Object Destination -EQ '/app/data/uploads').Name
        if (-not $values.PG_VOLUME -or -not $values.UPLOADS_VOLUME) { throw 'Could not locate the existing named data volumes.' }
        $backup = Join-Path $Root 'backups'
        New-Item -ItemType Directory -Force -Path $backup | Out-Null
        $dump = Join-Path $backup ('before-adoption-'+[DateTime]::UtcNow.ToString('yyyyMMddTHHmmss')+'.dump')
        $null = Invoke-Hidden docker @('exec',($project+'-postgres-1'),'pg_dump','-U','multica','-d','multica','-Fc') -OutputFile $dump -TimeoutSeconds 300
        Protect-LocalFile $dump
    } else {
        Assert-NewVolumesUnused $project
        $values.JWT_SECRET=[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32)).ToLowerInvariant()
        $values.POSTGRES_PASSWORD=[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32)).ToLowerInvariant()
        $values.PG_VOLUME=$project+'_pgdata'
        $values.UPLOADS_VOLUME=$project+'_backend_uploads'
    }
    $values.POSTGRES_IMAGE=$settings.images.postgres
    $values.BACKEND_IMAGE=$settings.images.backend
    $values.FRONTEND_IMAGE=$settings.images.frontend
    $values.FRONTEND_PORT=[string]$settings.frontend_port
    $values.BACKEND_PORT=[string]$settings.backend_port
    $values.APP_ENV=$settings.auth.app_env
    $values.MULTICA_DEV_VERIFICATION_CODE=$settings.auth.verification_code
    $values.AUTH_TOKEN_TTL=$settings.auth.token_ttl
    $values.LOGIN_EMAIL=$settings.email
    foreach ($value in $values.Values) { if ($value -notmatch '^[a-zA-Z0-9@:/._+-]+$') { throw 'Unsupported .env value; do not interpolate shell expressions or multiline secrets.' } }
    ($values.GetEnumerator() | Sort-Object Key | ForEach-Object { "$($_.Key)=$($_.Value)" }) | Set-Content -LiteralPath $privateEnv -Encoding utf8NoBOM
    Protect-LocalFile $privateEnv
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'compose.yml') -Destination (Join-Path $Root 'compose.yml') -Force
    Copy-Item -LiteralPath $SettingsFile -Destination (Join-Path $Root 'settings.json') -Force
    New-Item -ItemType Directory -Force -Path (Join-Path $Root 'scripts') | Out-Null
    foreach ($file in @('manage.ps1','new-goal.ps1','compact-docker-disk.ps1','scripts/common.ps1')) { Copy-Item -LiteralPath (Join-Path $PSScriptRoot $file) -Destination (Join-Path $Root $file) -Force }
    foreach ($file in @('coordination-local.txt','config/roles.json')) { Copy-Item -LiteralPath (Join-Path $PSScriptRoot $file) -Destination (Join-Path $Root ('assets/'+[IO.Path]::GetFileName($file))) -Force }
    foreach ($name in @('multica.exe','supervisor.exe')) { Copy-Item -LiteralPath (Join-Path $build $name) -Destination (Join-Path $BinRoot $name) -Force }
    foreach ($volume in @($values.PG_VOLUME,$values.UPLOADS_VOLUME)) { $null = Invoke-Hidden docker @('volume','create',$volume) }
    $render = Invoke-Compose $context @('config','--format','json')
    $plan = $render.Stdout | ConvertFrom-Json -AsHashtable
    foreach ($service in @('backend','frontend')) { if ($plan.services[$service].ports[0].host_ip -ne '127.0.0.1') { throw 'Refusing non-loopback publishing.' } }
    Write-Host 'Starting the local database, API and browser interface.'
    $null = Invoke-Compose $context @('up','-d') -TimeoutSeconds 600
    $baseUrl = "http://localhost:$($settings.backend_port)"
    $ready=$false
    for ($attempt=0; $attempt -lt 90; $attempt++) {
        try { $null = Invoke-LocalApi $baseUrl '/api/config'; $ready=$true; break } catch { Start-Sleep -Seconds 2 }
    }
    if (-not $ready) { throw 'Backend did not become ready. Check Docker Desktop and local container logs.' }
    foreach ($pair in @(@('server_url',$baseUrl),@('app_url',"http://localhost:$($settings.frontend_port)"),@('workspaces_root',$WorkspacesRoot),@('disable_auto_update','true'),@('disable_auto_reload','true'))) { Invoke-Multica $context @('config','set',$pair[0],$pair[1]) }
    Connect-LocalProfile $context -RenewLocalAuth:$RenewLocalAuth
    $workspace = Select-LocalWorkspace $context
    Write-JsonFile (Join-Path $Root 'config.json') @{cli=$context.Cli;profile=$settings.profile;workspaces_root=$WorkspacesRoot;codex_args=$settings.codex_args;log_dir=(Join-Path $Root 'logs')}
    Register-Supervisor $context
    Start-ScheduledTask -TaskName $settings.task_name
    $daemonReady=$false
    for ($attempt=0; $attempt -lt 30; $attempt++) {
        Start-Sleep -Seconds 1
        $native=Invoke-Multica $context @('daemon','status') -Json
        if ($native.status -eq 'running') { $daemonReady=$true; break }
    }
    if (-not $daemonReady) { throw 'Scheduled daemon did not become ready; inspect supervisor logs.' }
    $team = Initialize-LocalTeam $context $workspace -AdoptExisting:$AdoptExisting
    Complete-LocalOnboarding $context $workspace
    $state=@{format=1;installed_at=[DateTimeOffset]::UtcNow.ToString('o');upstream_commit=$settings.upstream_commit;cli=$context.Cli;cli_sha256=(Get-FileHash -LiteralPath $context.Cli -Algorithm SHA256).Hash.ToLowerInvariant();profile=$settings.profile;compose_project=$project;workspace_id=$workspace.id;workspace_slug=$workspace.slug;team=$team;pg_volume=$values.PG_VOLUME;uploads_volume=$values.UPLOADS_VOLUME;workspaces_root=$WorkspacesRoot;task_name=$settings.task_name}
    Write-JsonFile $statePath $state
    $pendingPath = Join-Path $Root 'pending-workspace.json'
    if (Test-Path -LiteralPath $pendingPath) { Remove-Item -LiteralPath $pendingPath }
    if (Test-Path -LiteralPath $bootstrapPath) { Remove-Item -LiteralPath $bootstrapPath }
    Write-Host "Ready: http://localhost:$($settings.frontend_port)/$($workspace.slug)/chat"
    Write-Host "Login address: $($settings.email); request a code, then enter $($settings.auth.verification_code)."
    Write-Host "Runtime files: $Root. No Multica source changes were applied."
} catch {
    if ($wasEnabled) { Enable-ScheduledTask -TaskName $settings.task_name | Out-Null }
    throw
}

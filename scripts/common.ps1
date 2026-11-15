Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Hidden {
    param([string]$Executable, [string[]]$Arguments = @(), [string]$WorkingDirectory,
          [string]$InputText, [hashtable]$Environment = @{}, [int]$TimeoutSeconds = 120,
          [switch]$AllowFailure, [string]$OutputFile)
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $Executable
    $start.UseShellExecute = $false
    # A hidden console can be inherited by grandchildren. CREATE_NO_WINDOW
    # alone can cause a descendant to create a new visible console.
    $start.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $start.CreateNoWindow = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.RedirectStandardInput = $true
    if ($WorkingDirectory) { $start.WorkingDirectory = $WorkingDirectory }
    foreach ($argument in $Arguments) { $start.ArgumentList.Add($argument) }
    foreach ($key in @($start.Environment.Keys)) {
        if ($key -like 'MULTICA_LOCAL_APPROVAL_*') { [void]$start.Environment.Remove($key) }
    }
    foreach ($key in $Environment.Keys) {
        if ($null -eq $Environment[$key]) { [void]$start.Environment.Remove($key) }
        else { $start.Environment[$key] = $Environment[$key] }
    }
    $start.Environment['GIT_TERMINAL_PROMPT'] = '0'
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $start
    $outputStream = $null
    try {
        if (-not $process.Start()) { throw 'Could not start process' }
        if ($OutputFile) {
            $outputStream = [IO.File]::Create($OutputFile)
            $stdout = $process.StandardOutput.BaseStream.CopyToAsync($outputStream)
        } else { $stdout = $process.StandardOutput.ReadToEndAsync() }
        $stderr = $process.StandardError.ReadToEndAsync()
        if ($InputText) { $process.StandardInput.Write($InputText) }
        $process.StandardInput.Close()
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            $process.Kill($true)
            $process.WaitForExit()
            throw "Process timed out: $([IO.Path]::GetFileName($Executable))"
        }
        $stdout.GetAwaiter().GetResult() | ForEach-Object { $captured = $_ }
        $errorText = $stderr.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0 -and -not $AllowFailure) {
            # Never include arguments, stdin or raw stderr: login responses and
            # provider diagnostics can contain credentials.
            throw "$([IO.Path]::GetFileName($Executable)) failed (exit $($process.ExitCode))"
        }
        return [pscustomobject]@{ ExitCode = $process.ExitCode; Stdout = $(if ($OutputFile) { '' } else { $captured }); Stderr = $errorText }
    } finally {
        if ($outputStream) { $outputStream.Dispose() }
        $process.Dispose()
    }
}

function Read-Settings {
    param([string]$Path)
    $settings = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable
    foreach ($key in 'profile', 'compose_project', 'task_name') {
        if ($settings[$key] -notmatch '^[a-zA-Z0-9][a-zA-Z0-9 ._-]{0,95}$') { throw "Invalid $key" }
    }
    if ($settings.profile -match ' ') { throw 'Profile cannot contain spaces' }
    if ($settings.compose_project -notmatch '^[a-z0-9][a-z0-9_-]*$') { throw 'Invalid compose project' }
    if ($settings.workspace.slug -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { throw 'Invalid workspace slug' }
    if ($settings.upstream_url -ne 'https://github.com/multica-ai/multica.git' -or $settings.upstream_commit -notmatch '^[a-f0-9]{40}$') { throw 'Use the reviewed upstream URL and an exact commit' }
    foreach ($key in 'frontend_port', 'backend_port') {
        if (($settings[$key] -isnot [int] -and $settings[$key] -isnot [long]) -or $settings[$key] -lt 1024 -or $settings[$key] -gt 65535) { throw "Invalid $key" }
    }
    if ($settings.frontend_port -eq $settings.backend_port) { throw 'Ports must differ' }
    if ($settings.email -notmatch '^[a-zA-Z0-9._+@-]+$' -or $settings.email -notmatch '@') { throw 'Invalid local login address' }
    if ($settings.auth.app_env -ne 'development' -or $settings.auth.verification_code -notmatch '^\d{6}$') { throw 'This installer supports local development authentication only' }
    if ($settings.auth.token_ttl -notmatch '^[1-9]\d*h$') { throw 'Use a positive auth TTL in hours' }
    if ($settings.root_guard.max_fires -lt 1 -or $settings.root_guard.max_fires -gt 1000) { throw 'Use a finite root guard with 1-1000 firings' }
    foreach ($duration in @($settings.root_guard.every,$settings.root_guard.expires_in)) {
        if ($duration -notmatch '^[1-9]\d*[smh]$') { throw 'Use positive finite root-guard durations' }
    }
    $requiredPolicy = '-c approval_policy="never" -c windows.sandbox="mxc" -c features.exec_permission_approvals=false -c features.request_permissions_tool=false'
    if ($settings.codex_args -ne $requiredPolicy) { throw 'Unexpected Codex security defaults; review before changing the installer' }
    foreach ($image in $settings.images.Values) {
        if ($image -notmatch '^[a-z0-9./-]+@sha256:[a-f0-9]{64}$') { throw 'Pin all images by digest' }
    }
    return $settings
}

function Write-JsonFile {
    param([string]$Path, $Value)
    $Value | ConvertTo-Json -Depth 25 | Set-Content -LiteralPath $Path -Encoding utf8NoBOM
}

function Protect-LocalFile {
    param([string]$Path)
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent().User
    # Set only the DACL. Re-applying Get-Acl's owner/audit sections can require
    # SeSecurityPrivilege and breaks an ordinary non-elevated installation.
    $acl = [Security.AccessControl.FileSecurity]::new()
    $acl.SetAccessRuleProtection($true, $false)
    $acl.SetAccessRule([Security.AccessControl.FileSystemAccessRule]::new($identity, 'FullControl', 'Allow'))
    $system = [Security.Principal.SecurityIdentifier]::new('S-1-5-18')
    $acl.SetAccessRule([Security.AccessControl.FileSystemAccessRule]::new($system, 'FullControl', 'Allow'))
    [IO.FileSystemAclExtensions]::SetAccessControl([IO.FileInfo]::new($Path), $acl)
}

function Invoke-Multica {
    param($Context, [string[]]$Arguments, [switch]$Json, [switch]$AllowFailure, [string]$InputText)
    $commandArgs = @('--profile', $Context.Settings.profile) + $Arguments
    if ($Json) { $commandArgs += @('--output', 'json') }
    $result = Invoke-Hidden -Executable $Context.Cli -Arguments $commandArgs -WorkingDirectory $Context.Root -InputText $InputText -AllowFailure:$AllowFailure -Environment @{MULTICA_CODEX_ARGS=$Context.Settings.codex_args}
    if ($AllowFailure) { return $result }
    if ($Json) { return ConvertFrom-Json -InputObject $result.Stdout -AsHashtable -NoEnumerate }
}

function Invoke-LocalApi {
    param([string]$BaseUrl, [string]$Path, [string]$Method = 'GET', $Body, [string]$Token)
    $uri = [Uri]($BaseUrl + $Path)
    if ($uri.Scheme -ne 'http' -or $uri.Host -ne 'localhost') { throw 'Local API must use http://localhost' }
    $handler = [Net.Http.HttpClientHandler]::new()
    $handler.AllowAutoRedirect = $false
    $handler.UseProxy = $false
    $client = [Net.Http.HttpClient]::new($handler)
    $client.Timeout = [TimeSpan]::FromSeconds(30)
    $request = [Net.Http.HttpRequestMessage]::new([Net.Http.HttpMethod]::new($Method), $uri)
    if ($Token) { $request.Headers.Authorization = [Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', $Token) }
    if ($null -ne $Body) { $request.Content = [Net.Http.StringContent]::new(($Body | ConvertTo-Json -Depth 10 -Compress), [Text.Encoding]::UTF8, 'application/json') }
    try {
        $response = $client.Send($request)
        try {
            if (-not $response.IsSuccessStatusCode) { throw "Local API $Path failed (HTTP $([int]$response.StatusCode))" }
            return ConvertFrom-Json -InputObject ($response.Content.ReadAsStringAsync().GetAwaiter().GetResult()) -AsHashtable -NoEnumerate
        } finally { $response.Dispose() }
    } finally { $request.Dispose(); $client.Dispose() }
}

function Invoke-Compose {
    param($Context, [string[]]$Arguments, [string]$OutputFile, [int]$TimeoutSeconds = 300)
    # Shell environment must not silently override the reviewed private .env.
    $envNames = @('POSTGRES_IMAGE','BACKEND_IMAGE','FRONTEND_IMAGE','POSTGRES_PASSWORD','JWT_SECRET','FRONTEND_PORT','BACKEND_PORT','APP_ENV','MULTICA_DEV_VERIFICATION_CODE','AUTH_TOKEN_TTL','LOGIN_EMAIL','PG_VOLUME','UPLOADS_VOLUME')
    $removed = @{}
    foreach ($key in $envNames) { $removed[$key] = $null }
    return Invoke-Hidden -Executable 'docker' -Arguments (@('compose','--project-name',$Context.Project,'--env-file',(Join-Path $Context.Root '.env'),'-f',(Join-Path $Context.Root 'compose.yml')) + $Arguments) -Environment $removed -OutputFile $OutputFile -TimeoutSeconds $TimeoutSeconds
}

function Register-Supervisor {
    param($Context)
    $supervisor = Join-Path (Split-Path $Context.Cli) 'supervisor.exe'
    $configuration = Join-Path $Context.Root 'config.json'
    $action = New-ScheduledTaskAction -Execute $supervisor -Argument ('"' + $configuration + '"')
    $login = New-ScheduledTaskTrigger -AtLogOn -User ([Security.Principal.WindowsIdentity]::GetCurrent().Name)
    $repeat = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1)
    $options = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 2) -StartWhenAvailable
    Register-ScheduledTask -TaskName $Context.Settings.task_name -Action $action -Trigger @($login,$repeat) -Settings $options -Description 'Stock local Multica daemon in a hidden inherited console.' -Force | Out-Null
}

function Assert-NewVolumesUnused {
    param([string]$Project)
    foreach ($volume in @(($Project+'_pgdata'),($Project+'_backend_uploads'))) {
        $existing=Invoke-Hidden docker @('volume','inspect',$volume) -AllowFailure
        if ($existing.ExitCode -eq 0) { throw 'Named data already exists without its private configuration. Restore it, adopt its stack or choose another Compose project.' }
    }
}

function Read-Installation {
    param([string]$Root)
    $Root = [IO.Path]::GetFullPath($Root)
    $state = Get-Content -LiteralPath (Join-Path $Root 'install-state.json') -Raw | ConvertFrom-Json -AsHashtable
    $settings = Read-Settings (Join-Path $Root 'settings.json')
    return @{Root=$Root; Settings=$settings; Cli=$state.cli; Project=$state.compose_project; State=$state}
}

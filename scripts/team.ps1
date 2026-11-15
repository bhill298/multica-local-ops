function Save-PendingWorkspace {
    param($Context, $Workspace)
    Write-JsonFile (Join-Path $Context.Root 'pending-workspace.json') @{id=$Workspace.id;profile=$Context.Settings.profile;settings_sha256=(Get-FileHash -LiteralPath (Join-Path $Context.Root 'settings.json') -Algorithm SHA256).Hash}
}

function Connect-LocalProfile {
    param($Context, [switch]$RenewLocalAuth)
    try {
        # auth status exits zero even for expired credentials; use a real API call.
        $null = Invoke-Multica $Context @('workspace','list') -Json
        if (-not $RenewLocalAuth) { return }
    } catch { }
    $settings = $Context.Settings
    $baseUrl = "http://localhost:$($settings.backend_port)"
    $null = Invoke-LocalApi $baseUrl '/auth/send-code' 'POST' @{email=$settings.email}
    $login = Invoke-LocalApi $baseUrl '/auth/verify-code' 'POST' @{email=$settings.email; code=$settings.auth.verification_code}
    $workspaces = Invoke-LocalApi $baseUrl '/api/workspaces' -Token $login.token
    if (-not ($workspaces | Where-Object slug -EQ $settings.workspace.slug)) {
        $created = Invoke-LocalApi $baseUrl '/api/workspaces' 'POST' @{name=$settings.workspace.name; slug=$settings.workspace.slug; issue_prefix=$settings.workspace.issue_prefix; context=$settings.workspace.context} -Token $login.token
        $Context.NewWorkspace = $true
        Save-PendingWorkspace $Context $created
    }
    # Normal local login and a revocable 90-day CLI PAT; no provider credentials.
    $pat = Invoke-LocalApi $baseUrl '/api/tokens/' 'POST' @{name='Multica local installer'; expires_in_days=90} -Token $login.token
    try { Invoke-Multica $Context @('login','--token') -InputText ($pat.token + "`n") }
    finally { $pat = $null; $login = $null }
}

function Select-LocalWorkspace {
    param($Context)
    $settings = $Context.Settings
    $workspaces = Invoke-Multica $Context @('workspace','list') -Json
    $workspace = $workspaces | Where-Object slug -EQ $settings.workspace.slug | Select-Object -First 1
    if (-not $workspace) {
        $workspace = Invoke-Multica $Context @('workspace','create','--name',$settings.workspace.name,'--slug',$settings.workspace.slug,'--issue-prefix',$settings.workspace.issue_prefix,'--context',$settings.workspace.context) -Json
        $Context.NewWorkspace = $true
        Save-PendingWorkspace $Context $workspace
    }
    $pendingPath = Join-Path $Context.Root 'pending-workspace.json'
    if (-not $Context.NewWorkspace -and (Test-Path -LiteralPath $pendingPath)) {
        $pending = Get-Content -LiteralPath $pendingPath -Raw | ConvertFrom-Json -AsHashtable
        $hash = (Get-FileHash -LiteralPath (Join-Path $Context.Root 'settings.json') -Algorithm SHA256).Hash
        if ($pending.id -ne $workspace.id -or $pending.profile -ne $settings.profile -or $pending.settings_sha256 -ne $hash) { throw 'Interrupted setup has different settings. Preserve it and review before reconfiguring its workspace.' }
        $Context.NewWorkspace = $true
    }
    Invoke-Multica $Context @('workspace','switch',$workspace.id)
    Invoke-Multica $Context @('workspace','watch',$workspace.id)
    return $workspace
}

function Initialize-LocalTeam {
    param($Context, $Workspace, [switch]$AdoptExisting)
    $settings = $Context.Settings
    $runtime = $null
    for ($attempt=0; $attempt -lt 60; $attempt++) {
        $runtimes = Invoke-Multica $Context @('--workspace-id',$Workspace.id,'runtime','list') -Json
        $runtime = $runtimes | Where-Object { $_.provider -eq 'codex' -and $_.status -eq 'online' } | Select-Object -First 1
        if ($runtime) { break }
        Start-Sleep -Seconds 2
    }
    if (-not $runtime) { throw 'No online native Codex runtime. Check codex login and supervisor logs, then rerun.' }
    $existing = Invoke-Multica $Context @('--workspace-id',$Workspace.id,'agent','list') -Json
    $roles = Get-Content -LiteralPath (Join-Path $Context.Root 'assets/roles.json') -Raw | ConvertFrom-Json -AsHashtable
    $team = [ordered]@{}
    if (-not $Context.NewWorkspace) {
        if (-not $AdoptExisting -and -not $Context.PreviouslyInstalled) { throw 'Existing workspace: use -AdoptExisting to preserve its team, or choose a new workspace slug.' }
        foreach ($name in $roles.Keys) {
            $match = $existing | Where-Object name -EQ $name | Select-Object -First 1
            if (-not $match) { throw "Existing workspace lacks $name. Installer will not silently rewrite or reuse old sessions." }
            $team[$name] = $match.id
        }
        return $team
    }
    $contract = Get-Content -LiteralPath (Join-Path $Context.Root 'assets/coordination-local.txt') -Raw
    foreach ($name in $roles.Keys) {
        $isWorker = $name -in @('Builder','Researcher')
        $model = $(if ($isWorker) { $settings.worker_model } else { $settings.lead_model })
        $effort = $(if ($isWorker) { $settings.worker_effort } else { $settings.lead_effort })
        $instructions = $contract + "`nRole: " + $roles[$name]
        $flags = @('--runtime-id',$runtime.id,'--model',$model,'--thinking-level',$effort,'--max-concurrent-tasks','1','--custom-args','[]','--instructions',$instructions)
        $match = $existing | Where-Object name -EQ $name | Select-Object -First 1
        if ($match) { $agent = Invoke-Multica $Context (@('--workspace-id',$Workspace.id,'agent','update',$match.id) + $flags) -Json }
        else { $agent = Invoke-Multica $Context (@('--workspace-id',$Workspace.id,'agent','create','--name',$name,'--visibility','private') + $flags) -Json }
        $team[$name] = $agent.id
    }
    $directory = "`nFresh team: " + (($team.GetEnumerator() | ForEach-Object { "$($_.Key) $($_.Value)" }) -join ', ') + '. Delegate only to this team. Each actor runs one task at a time.'
    foreach ($name in @('Mika','Code Lead','Research Lead')) {
        $agent = Invoke-Multica $Context @('--workspace-id',$Workspace.id,'agent','get',$team[$name]) -Json
        $null = Invoke-Multica $Context @('--workspace-id',$Workspace.id,'agent','update',$team[$name],'--instructions',($agent.instructions + $directory)) -Json
    }
    return $team
}

function Complete-LocalOnboarding {
    param($Context, $Workspace)
    # Use the selected profile's own application credential for the ordinary
    # onboarding API. No provider home/token is read, exported or copied.
    $path = Join-Path $env:USERPROFILE ('.multica/profiles/'+$Context.Settings.profile+'/config.json')
    $localProfile = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -AsHashtable
    $url = "http://localhost:$($Context.Settings.backend_port)"
    if ($localProfile.server_url.TrimEnd('/') -ne $url) { throw 'Profile points to another server; refusing onboarding request.' }
    try {
        $me = Invoke-LocalApi $url '/api/me' -Token $localProfile.token
        if (-not $me.onboarded_at) {
            $null = Invoke-LocalApi $url '/api/me/onboarding/complete' 'POST' @{completion_path='skip_existing';workspace_id=$Workspace.id} -Token $localProfile.token
        }
    } finally { $localProfile = $null }
}

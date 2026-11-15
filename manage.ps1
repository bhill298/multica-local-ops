#Requires -Version 7.2
param(
    [ValidateSet('Status','Start','Stop','Backup')][string]$Action = 'Status',
    [string]$Root = (Join-Path $env:USERPROFILE '.multica/local-ops')
)
. (Join-Path $PSScriptRoot 'scripts/common.ps1')
$context = Read-Installation $Root
switch ($Action) {
    'Status' {
        $status = Invoke-Multica $context @('daemon','status') -Json
        $task = Get-ScheduledTask -TaskName $context.Settings.task_name
        $hashMatches=(Get-FileHash -LiteralPath $context.Cli -Algorithm SHA256).Hash.ToLowerInvariant() -eq $context.State.cli_sha256
        [ordered]@{url="http://localhost:$($context.Settings.frontend_port)/$($context.State.workspace_slug)/chat";daemon=$status.status;pid=$status['pid'];active_tasks=$status['active_task_count'];supervisor=[string]$task.State;source_commit=$context.State.upstream_commit;selected_source_patches=0;binary_matches_manifest=$hashMatches;runtime_root=$context.Root} | ConvertTo-Json
    }
    'Start' {
        $null = Invoke-Compose $context @('up','-d')
        Enable-ScheduledTask -TaskName $context.Settings.task_name | Out-Null
        Start-ScheduledTask -TaskName $context.Settings.task_name
        Write-Host 'Local stack and scheduled supervisor started.'
    }
    'Stop' {
        $status = Invoke-Multica $context @('daemon','status') -Json
        if ($status['active_task_count'] -gt 0) { throw 'Work is active. Finish or cancel it in Multica before stopping.' }
        Disable-ScheduledTask -TaskName $context.Settings.task_name | Out-Null
        Invoke-Multica $context @('daemon','stop')
        $null = Invoke-Compose $context @('stop')
        Write-Host 'Stopped. Database, uploads, settings and provider logins were preserved.'
    }
    'Backup' {
        $status = Invoke-Multica $context @('daemon','status') -Json
        if ($status['active_task_count'] -gt 0) { throw 'Wait for active work to finish before making this combined backup.' }
        $destination = Join-Path $context.Root ('backups/'+[DateTime]::UtcNow.ToString('yyyyMMddTHHmmss'))
        New-Item -ItemType Directory -Path $destination | Out-Null
        $database = Join-Path $destination 'database.dump'
        $null = Invoke-Compose $context @('exec','-T','postgres','pg_dump','-U','multica','-d','multica','-Fc') -OutputFile $database
        Protect-LocalFile $database
        $uploads = Join-Path $destination 'uploads.tar'
        $null = Invoke-Hidden docker @('run','--rm','--network','none','--mount',("type=volume,source="+$context.State.uploads_volume+",target=/data,readonly"),$context.Settings.images.postgres,'tar','-C','/data','-cf','-','.') -OutputFile $uploads -TimeoutSeconds 300
        Protect-LocalFile $uploads
        foreach ($file in @('.env','install-state.json','settings.json','config.json')) {
            $target = Join-Path $destination $file
            Copy-Item -LiteralPath (Join-Path $context.Root $file) -Destination $target
            Protect-LocalFile $target
        }
        Write-Host "Backup saved to $destination. It contains private server secrets; keep it out of Git."
    }
}

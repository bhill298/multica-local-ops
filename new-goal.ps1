#Requires -Version 7.2
param(
    [Parameter(Mandatory)][string]$Title,
    [Parameter(Mandatory)][string]$OutcomeFile,
    [string]$ProjectId,
    [string]$Root = (Join-Path $env:USERPROFILE '.multica/local-ops')
)
. (Join-Path $PSScriptRoot 'scripts/common.ps1')
$context = Read-Installation $Root
$wid = $context.State.workspace_id
if ($ProjectId) {
    $null = Invoke-Multica $context @('--workspace-id',$wid,'project','get',$ProjectId) -Json
}
$temporary = Join-Path $context.Root ([IO.Path]::GetRandomFileName()+'.txt')
try {
    $description = Get-Content -LiteralPath $OutcomeFile -Raw
    if ($ProjectId) { $description += "`nAuthorized project ID: $ProjectId. Bind every project-lead/worker/reviewer child with --project $ProjectId and verify project_id before dispatch." }
    $description += "`nThe operator has registered a finite independent root backstop before first dispatch. Preserve it until actual accepted closure or an honest external blocker; do not duplicate it. Apply the coordination contract and disable obsolete guards at closure."
    Set-Content -LiteralPath $temporary -Value $description -Encoding utf8NoBOM
    Protect-LocalFile $temporary
    $issue = Invoke-Multica $context @('--workspace-id',$wid,'issue','create','--assignee',$context.State.team.Mika,'--status','backlog','--title',$Title,'--description-file',$temporary) -Json
    $instruction = "Reconcile owning ROOT $($issue.identifier) ($($issue.id)). Inspect current descendants, actual active runs, evidence, independent review and supplied decisions. Accept verified descendants and close this root when justified. Preserve Done. Recover real failures with a verified bounded dispatch, avoid duplicates/status-only loops and disable obsolete guards. A terminal child is not acceptance of the root. Report genuine external blockers and keep unrelated work moving."
    Set-Content -LiteralPath $temporary -Value $instruction -Encoding utf8NoBOM
    $guard = $context.Settings.root_guard
    $wakeup = Invoke-Multica $context @('--workspace-id',$wid,'issue','wakeup','create',$issue.id,'--kind','every','--every',$guard.every,'--max-fires',[string]$guard.max_fires,'--expires-in',$guard.expires_in,'--agent-id',$context.State.team.Mika,'--instruction-file',$temporary) -Json
    Invoke-Multica $context @('--workspace-id',$wid,'issue','update',$issue.id,'--status','todo','--no-start')
    $run = Invoke-Multica $context @('--workspace-id',$wid,'issue','rerun',$issue.id) -Json
    [ordered]@{issue=$issue.identifier;issue_id=$issue.id;run_id=$run.id;guard_id=$wakeup.id} | ConvertTo-Json
} finally {
    if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary }
}

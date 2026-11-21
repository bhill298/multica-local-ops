#Requires -Version 7.3
[CmdletBinding(DefaultParameterSetName='Remote')]
param(
    [Parameter(Mandatory,ParameterSetName='Remote')][ValidatePattern('^[0-9a-f]{40}$')][string]$Commit,
    [Parameter(Mandatory,ParameterSetName='Local')][string]$SourceRoot
)
$ErrorActionPreference='Stop'

function Read-Source([string]$Path) {
    if ($SourceRoot) { return Get-Content -LiteralPath (Join-Path $SourceRoot $Path) -Raw }
    $url="https://raw.githubusercontent.com/multica-ai/multica/$Commit/$Path"
    try { $content=(Invoke-WebRequest $url -TimeoutSec 25).Content }
    catch { throw "Cannot verify Multica SQL compatibility at $Commit ($Path): $($_.Exception.Message)" }
    if ($content -is [byte[]]) { return [Text.Encoding]::UTF8.GetString($content) }
    return $content
}

function Struct-Fields([string]$Text,[string]$Type) {
    $body=[regex]::Match($Text,"(?ms)^type\s+$Type\s+struct\s*\{(.*?)^\}").Groups[1].Value
    [regex]::Matches($body,'(?m)^\s*\w+\s+\S+\s+`json:"(\w+)"`') | ForEach-Object { $_.Groups[1].Value }
}

$missing=[Collections.Generic.List[string]]::new()
function Check-Names([string]$Area,[string[]]$Found,[string[]]$Required) {
    foreach ($name in $Required) {
        if ($name -cnotin $Found) { $missing.Add("$Area.$name") }
    }
}

# Current sqlc models and live queries are better evidence than old migrations,
# which still contain names even after a later migration removes them.
$models=Read-Source 'server/pkg/db/generated/models.go'
$user=@(Struct-Fields $models 'User')
Check-Names 'agent_task_queue' @(Struct-Fields $models 'AgentTaskQueue') @('status')
Check-Names 'user' $user @('id','email','updated_at','onboarding_questionnaire')
foreach ($query in @(@('agent','agent_task_queue'),@('user','user'))) {
    $sql=(Read-Source "server/pkg/db/queries/$($query[0]).sql") -replace '(?s)/\*.*?\*/|(?m)--[^\r\n]*',''
    $table=$query[1]
    if ($sql -notmatch ('\b(?:FROM|UPDATE|INTO)\s+(?:public\.)?(?:"{0}"|{0})(?=\s|[,;(]|$)' -f $table)) {
        $missing.Add("table $($query[1]) in active queries")
    }
}

$handler=Read-Source 'server/internal/handler/agent_access.go'
$terminal=[regex]::Match($handler,'(?ms)^func isTerminalTaskStatus\([^)]*\)\s*bool\s*\{(.*?)^\}').Groups[1].Value
$terminal=$terminal -replace '(?s)/\*.*?\*/|(?m)//[^\r\n]*',''
$cases=[regex]::Matches($terminal,'(?s)\bcase\s+([^:]+):\s*return true\b')
$labels=@(foreach ($case in $cases) {
    [regex]::Matches($case.Groups[1].Value,'"([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
})
$expected=@('completed','failed','cancelled')
Check-Names 'terminal status' $labels $expected
foreach ($extra in $labels) { if ($extra -cnotin $expected) { $missing.Add("unreviewed terminal status $extra") } }

$onboarding=Read-Source 'server/internal/handler/onboarding.go'
Check-Names 'questionnaire' @(Struct-Fields $onboarding 'questionnaireAnswers') @(
    'version','source','source_other','source_skipped','role','role_other','role_skipped','use_case','use_case_other','use_case_skipped')
if ($onboarding -cnotmatch '(?m)^\s*const\s+questionnaireSchemaVersion\s*=\s*2[ \t]*(?://[^\r\n]*)?\r?$') {$missing.Add('questionnaire schema version 2')}

if ('star_prompt_shown_count' -cin $user -or 'star_prompt_starred_at' -cin $user) {
    Check-Names 'user' $user @('star_prompt_shown_count','star_prompt_starred_at')
    $star=Read-Source 'server/internal/handler/star_prompt.go'
    if ($star -cnotmatch '(?m)^\s*starPromptMaxShowings\s*=\s*2[ \t]*(?://[^\r\n]*)?\r?$') {$missing.Add('star prompt limit 2')}
} else {
    Write-Warning 'No star-prompt columns in candidate source. The optional star-prompt SQL will skip this feature if the live schema agrees.'
}
if ($missing.Count) {
    throw "Review Multica SQL compatibility before upgrading: $($missing -join '; '). See docs/update-multica.md."
}

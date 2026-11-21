#Requires -Version 7.3
[CmdletBinding(DefaultParameterSetName='Remote')]
param(
    [Parameter(Mandatory,ParameterSetName='Remote')][ValidatePattern('^[0-9a-f]{40}$')][string]$Commit,
    [Parameter(Mandatory,ParameterSetName='Local')][string]$SourceRoot
)
$ErrorActionPreference='Stop'

function Read-Source([string]$Path,[switch]$Optional) {
    if ($SourceRoot) {
        $file=Join-Path $SourceRoot $Path
        if ($Optional -and !(Test-Path -LiteralPath $file -PathType Leaf)){return ''}
        return Get-Content -LiteralPath $file -Raw
    }
    $url="https://raw.githubusercontent.com/multica-ai/multica/$Commit/$Path"
    try { $content=(Invoke-WebRequest $url -TimeoutSec 25 -MaximumRetryCount 1 -RetryIntervalSec 1).Content }
    catch {
        if ($Optional -and $_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 404){return ''}
        throw "Cannot verify Multica SQL compatibility at $Commit ($Path): $($_.Exception.Message)"
    }
    if ($content -is [byte[]]) { return [Text.Encoding]::UTF8.GetString($content) }
    return $content
}

function Struct-Fields([string]$Text,[string]$Type) {
    $body=[regex]::Match($Text,"(?ms)^[ \t]*type\s+$Type\s+struct\s*\{(.*?)^[ \t]*\}").Groups[1].Value
    [regex]::Matches($body,'(?m)^[ \t]*\w+\s+[^\r\n`]+`[^`\r\n]*?\bjson:"(\w+)(?:,[^"]*)?"') | ForEach-Object { $_.Groups[1].Value }
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
    if ($sql -notmatch ('\b(?:FROM|UPDATE|INTO)\s+(?:(?:"public"|public)\s*\.\s*)?(?:"{0}"|{0})(?=\s|[,;(]|$)' -f $table)) {
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
if (!$labels.Count -and $terminal.Trim() -cmatch '^return\s+(?<var>\w+)\s*==\s*"\w+"(?:\s*\|\|\s*\k<var>\s*==\s*"\w+")*;?$') {
    $labels=@([regex]::Matches($terminal,'"([^"]+)"') | ForEach-Object {$_.Groups[1].Value})
}
if (!$labels.Count){throw 'Cannot verify the queue idle check: terminal states could not be identified in server/internal/handler/agent_access.go. Review the candidate classifier before updating.'}
$expected=@('completed','failed','cancelled')
Check-Names 'terminal status' $labels $expected
foreach ($extra in $labels) { if ($extra -cnotin $expected) { $missing.Add("unreviewed terminal status $extra") } }

$onboarding=Read-Source 'server/internal/handler/onboarding.go' -Optional
$answers=@(Struct-Fields $onboarding 'questionnaireAnswers')
if ($answers.Count) {Check-Names 'questionnaire' $answers @(
    'version','source','source_other','source_skipped','role','role_other','role_skipped','use_case','use_case_other','use_case_skipped')
} else {Write-Warning 'Questionnaire handler layout changed. Verify the optional skip preferences after updating.'}

function Check-PromptConstant([string]$Source,[string]$Name,[string]$Label) {
    $match=[regex]::Match($Source,"(?m)^[ \t]*(?:const\s+)?$Name(?:[ \t]+\w+)?[ \t]*=[ \t]*(\d+)[ \t]*;?[ \t]*(?://[^\r\n]*)?\r?$")
    if (!$match.Success){Write-Warning "Cannot infer optional $Label from $Name. Verify prompt behavior after updating."}
    elseif ([int]$match.Groups[1].Value -ne 2){$missing.Add("$Label 2 (candidate: $($match.Groups[1].Value))")}
}
Check-PromptConstant $onboarding 'questionnaireSchemaVersion' 'questionnaire schema version'

if ('star_prompt_shown_count' -cin $user -or 'star_prompt_starred_at' -cin $user) {
    Check-Names 'user' $user @('star_prompt_shown_count','star_prompt_starred_at')
    $star=Read-Source 'server/internal/handler/star_prompt.go' -Optional
    Check-PromptConstant $star 'starPromptMaxShowings' 'star prompt limit'
} else {
    Write-Warning 'No star-prompt columns in candidate source. The optional star-prompt SQL will skip this feature if the live schema agrees.'
}
if ($missing.Count) {
    throw "Review Multica SQL compatibility before upgrading: $($missing -join '; '). See docs/update-multica.md."
}

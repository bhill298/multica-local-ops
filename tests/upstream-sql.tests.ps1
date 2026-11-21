# Runs under installer.tests.ps1's disposable directory. No network or database.
param([Parameter(Mandatory)][string]$Fixture)
$ErrorActionPreference='Stop'
$check=Join-Path $PSScriptRoot '../hyperv/Test-UpstreamSql.ps1'
$generated=Join-Path $Fixture server/pkg/db/generated
$queries=Join-Path $Fixture server/pkg/db/queries
$handlers=Join-Path $Fixture server/internal/handler
$null=New-Item -ItemType Directory -Force -Path $generated,$queries,$handlers
function New-Struct([string]$Name,[string[]]$Fields) {
    "type $Name struct {"
    foreach ($field in $Fields) { '    Field_{0} string `json:"{0}"`' -f $field }
    '}'
}
$fields='id','email','updated_at','onboarding_questionnaire','star_prompt_shown_count','star_prompt_starred_at'
$models=@(New-Struct User $fields) + @(New-Struct AgentTaskQueue 'status')
$models | Set-Content "$generated/models.go"
'SELECT id FROM "user";' | Set-Content "$queries/user.sql"
'SELECT status FROM public.agent_task_queue;' | Set-Content "$queries/agent.sql"
@'
func isTerminalTaskStatus(status string) bool {
    switch status {
    case "cancelled", "failed", "completed":
        return true
    }
    return false
}
'@ | Set-Content "$handlers/agent_access.go"
$questionnaire=New-Struct questionnaireAnswers @('source','role','use_case','version','source_skipped','role_skipped','use_case_skipped','source_other','role_other','use_case_other')
@('const questionnaireSchemaVersion = 2') + $questionnaire | Set-Content "$handlers/onboarding.go"
'    starPromptMaxShowings = 2' | Set-Content "$handlers/star_prompt.go"
& $check -SourceRoot $Fixture

foreach ($case in @(
    @("$generated/models.go",'json:"status"','json:"state"','agent_task_queue.status'),
    @("$generated/models.go",'json:"email"','json:"address"','user.email'),
    @("$generated/models.go",'star_prompt_starred_at','starred_at','user.star_prompt_starred_at'),
    @("$queries/agent.sql",'FROM public.agent_task_queue','FROM tasks -- FROM agent_task_queue','table agent_task_queue'),
    @("$handlers/agent_access.go",'"failed"','"errored"','terminal status.failed'),
    @("$handlers/agent_access.go",'"failed"','"failed", "retired"','unreviewed terminal status retired'),
    @("$handlers/onboarding.go",'role_skipped','skip_role','questionnaire.role_skipped'),
    @("$handlers/onboarding.go",'Version = 2','Version = 3','questionnaire schema version 2'),
    @("$handlers/star_prompt.go",' = 2',' = 2 + 1','star prompt limit 2')
)) {
    $file,$old,$new,$expected=$case
    $original=[IO.File]::ReadAllText($file)
    [IO.File]::WriteAllText($file,$original.Replace($old,$new))
    $message=''
    try { & $check -SourceRoot $Fixture } catch { $message=$_.Exception.Message }
    finally { [IO.File]::WriteAllText($file,$original) }
    if (!$message.Contains($expected)) { throw "Expected $expected in compatibility failure. Got: $message" }
}

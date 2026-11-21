#Requires -Version 7.3
param([Parameter(Mandatory)]$Pins,[Parameter(Mandatory)][string]$Name)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$true
$repo=Split-Path $PSScriptRoot
$path='hyperv/initial-release.json'
$file=Join-Path $repo $path
if ($Pins.commit -cnotmatch '^[a-f0-9]{40}\z' -or
    $Pins.backend -cnotmatch '^ghcr\.io/multica-ai/multica-backend@sha256:[a-f0-9]{64}\z' -or
    $Pins.frontend -cnotmatch '^ghcr\.io/multica-ai/multica-web@sha256:[a-f0-9]{64}\z' -or
    ($Pins.version -and $Pins.version -cnotmatch '^v\d+\.\d+\.\d+\z')) {throw 'Invalid installed Multica release pins.'}

$original=[IO.File]::ReadAllText($file)
$skip=''
if (!(Test-Path -LiteralPath (Join-Path $repo '.git')) -or !(Get-Command git -ErrorAction SilentlyContinue)) {
    $skip='Git checkout or Git executable unavailable'
} else {
    $dirty=git -C $repo status --porcelain=v1 --untracked-files=all -- $path
    if ($dirty) {$skip="$path already has staged, unstaged, or untracked changes"}
    elseif ((git -C $repo ls-files -v -- $path) -cne "H $path") {$skip="$path is untracked or has special Git index flags"}
}
if ($skip){Write-Warning "Skipping auto-commit: $skip."}

$old=$original | ConvertFrom-Json -AsHashtable
if ($old.commit -ceq $Pins.commit -and $old.backend -ceq $Pins.backend -and $old.frontend -ceq $Pins.frontend) {
    Write-Output "Fresh-install pins already match $Name ($($Pins.commit))."; return
}
function ReleaseLabel($Version,[string]$Commit) {
    if ($Version -cmatch '^v\d+\.\d+\.\d+\z'){return $Version}
    if ($Commit -cmatch '^[0-9a-f]{40}\z'){return $Commit.Substring(0,12)}
    return 'unknown'
}
$sameCommit=$old.commit -ceq $Pins.commit
$from=ReleaseLabel $old.version $old.commit
$to=ReleaseLabel $Pins.version $Pins.commit
if ($sameCommit -and !$Pins.version){$to=$from}
$message=if ($sameCommit) {"Refresh pinned images for $to"} elseif ($from -eq $to) {
    "Upgrade pinned version from $from ($($old.commit.Substring(0,8))) to $to ($($Pins.commit.Substring(0,8)))"
} else {"Upgrade pinned version from $from to $to"}
foreach ($key in 'commit','backend','frontend') {$old[$key]=$Pins.$key}
if ($Pins.version){$old['version']=$Pins.version} elseif (!$sameCommit){$old.Remove('version')}
$content=(($old | ConvertTo-Json -Depth 100).Replace("`r`n","`n")+"`n")
$tmp="$file.$([guid]::NewGuid()).tmp"
try {
    [IO.File]::WriteAllText($tmp,$content)
    if ([IO.File]::ReadAllText($file) -cne $original){throw "$path changed during promotion. Retry after reviewing it."}
    [IO.File]::Move($tmp,$file,$true)
} finally {if (Test-Path -LiteralPath $tmp){Remove-Item -LiteralPath $tmp}}
if ($skip){Write-Output "Promoted $Name. Review $path and commit it manually."; return}

# A path-limited commit leaves unrelated staged changes in the index.
if ([IO.File]::ReadAllText($file) -cne $content -or (git -C $repo diff --cached --name-only -- $path)){
    Write-Warning "$path changed again during promotion. Review and commit it manually."; return
}
git -C $repo commit --only -m $message -- $path

param([Parameter(Mandatory)][string]$Fixture)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$true
$null=New-Item -ItemType Directory -Path "$Fixture/hyperv" -Force
Copy-Item "$PSScriptRoot/../hyperv/Promote-ReleasePins.ps1" "$Fixture/hyperv/"
$helper="$Fixture/hyperv/Promote-ReleasePins.ps1"
$path='hyperv/initial-release.json'
$file=Join-Path $Fixture $path
$old=[ordered]@{version='v1.0.0';commit='a'*40;backend='ghcr.io/multica-ai/multica-backend@sha256:'+('1'*64);frontend='ghcr.io/multica-ai/multica-web@sha256:'+('2'*64)}
$new=[pscustomobject]@{version='v1.1.0';commit='b'*40;backend=$old.backend;frontend=$old.frontend}
$old | ConvertTo-Json | Set-Content -LiteralPath $file
git -C $Fixture init -q
git -C $Fixture config user.name Fixture
git -C $Fixture config user.email fixture@example.invalid
git -C $Fixture config commit.gpgSign false
git -C $Fixture add -- $path
git -C $Fixture commit -qm 'Initial fixture'
'unrelated staged edit' | Set-Content "$Fixture/other.txt"
git -C $Fixture add -- other.txt
$other=git -C $Fixture rev-parse ':other.txt'
& $helper -Name fixture -Pins $new | Out-Null
if ((git -C $Fixture log -1 --format=%s) -ne 'Upgrade pinned version from v1.0.0 to v1.1.0' -or
    (git -C $Fixture diff-tree --no-commit-id --name-only -r HEAD) -ne $path -or
    (git -C $Fixture diff --cached --name-only) -ne 'other.txt' -or (git -C $Fixture rev-parse ':other.txt') -ne $other) {
    throw 'Clean promotion did not produce an isolated version commit.'
}
$head=git -C $Fixture rev-parse HEAD
& $helper -Name fixture -Pins $new | Out-Null
if ((git -C $Fixture rev-parse HEAD) -ne $head){throw 'Matching pins created a commit.'}
foreach ($state in 'unstaged','staged','both') {
    # Restore only this disposable fixture's pin file between cases.
    git -C $Fixture restore --source=HEAD --staged --worktree -- $path
    $doc=Get-Content $file -Raw | ConvertFrom-Json -AsHashtable
    $doc['note']='existing edit'
    $doc | ConvertTo-Json | Set-Content $file
    if ($state -ne 'unstaged'){git -C $Fixture add -- $path}
    if ($state -eq 'both'){$doc.note='additional working edit'; $doc | ConvertTo-Json | Set-Content $file}
    $index=git -C $Fixture rev-parse ":$path"
    & $helper -Name fixture -Pins ([pscustomobject]$old) -WarningVariable warn -WarningAction SilentlyContinue | Out-Null
    $result=Get-Content $file -Raw | ConvertFrom-Json
    if ("$warn" -notmatch 'Skipping auto-commit' -or (git -C $Fixture rev-parse HEAD) -ne $head -or
        (git -C $Fixture rev-parse ":$path") -ne $index -or $result.note -ne $doc.note -or $result.commit -ne $old.commit) {
        throw "Promotion mishandled a $state pin file."
    }
}

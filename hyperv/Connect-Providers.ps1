#Requires -Version 7.3
param([string]$Name='Multica-Ubuntu',[string]$Directory="$env:LOCALAPPDATA/MulticaVM/media")
$ErrorActionPreference='Stop'
$choices=@('codex','claude','agy')
Write-Host 'Optional provider sign-in. Each selected provider needs one login for the daily and admin workers.'
do {
    try {
        $answer=Read-Host 'Choose providers (codex, claude, agy), all, or press Enter for none'
    } catch [System.Management.Automation.PSInvalidOperationException] {
        return  # PowerShell started with -NonInteractive.
    }
    if (!$answer -or !$answer.Trim() -or $answer.Trim() -eq 'none') { return }
    $selected=if ($answer.Trim() -eq 'all') { $choices } else {
        $answer.Trim().ToLowerInvariant() -split '[,\s]+' | Where-Object { $_ } | Select-Object -Unique
    }
    $invalid=@($selected | Where-Object { $_ -notin $choices })
    if ($invalid.Count) { Write-Host 'Choose only codex, claude, agy, all, or none.' }
} while ($invalid.Count)

foreach ($provider in $selected) {
    try {
        & "$PSScriptRoot/Connect-Guest.ps1" -Name $Name -Directory $Directory -Action Auth -Provider $provider
    } catch {
        Write-Warning "Could not finish $provider sign-in. You can retry with Connect-Guest.ps1 -Action Auth -Provider $provider."
    }
}

#Requires -Version 7.2
param(
    [string]$OutputFile = (Join-Path $PSScriptRoot 'mcp.local.json'),
    [string]$NodePath = (Get-Command node -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source,
    [string]$PowerShellPath = (Get-Process -Id $PID).Path
)
$ErrorActionPreference='Stop'
foreach($path in @($NodePath,$PowerShellPath)) {
    if(-not [IO.Path]::IsPathFullyQualified($path) -or -not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw 'Choose an existing absolute executable path'
    }
}
$configuration=@{mcpServers=@{officeFixture=@{
    command=$NodePath
    args=@((Join-Path $PSScriptRoot 'server.mjs'))
    env=@{MULTICA_OFFICE_PWSH=$PowerShellPath}
}}}
$configuration|ConvertTo-Json -Depth 8|Set-Content -LiteralPath $OutputFile -Encoding utf8NoBOM
Write-Output ([IO.Path]::GetFullPath($OutputFile))

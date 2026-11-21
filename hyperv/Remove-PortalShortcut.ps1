param([Parameter(Mandatory)][string]$Name,[Parameter(Mandatory)][string]$ProfileDir)
$shortcut=Join-Path ([Environment]::GetFolderPath('Programs')) "$Name Management.lnk"
if (Test-Path -LiteralPath $shortcut) {
    $link=(New-Object -ComObject WScript.Shell).CreateShortcut($shortcut)
    $pair=Join-Path $ProfileDir 'portal/open-management.html'
    if ($link.Arguments -eq ('"'+$pair+'"')) {Remove-Item -LiteralPath $shortcut -Force}
}

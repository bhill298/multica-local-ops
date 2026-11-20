#Requires -Version 7.2
[CmdletBinding()]
param([string]$Directory = "$env:LOCALAPPDATA/MulticaVM/media", [string]$SourceIso)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
$release = Get-Content "$PSScriptRoot/../linux-guest/release.json" -Raw | ConvertFrom-Json
$dir = (New-Item -ItemType Directory -Force -Path $Directory).FullName
$keyRoot = (New-Item -ItemType Directory -Force -Path (Join-Path (Split-Path $dir) 'keys')).FullName
$key = Join-Path $keyRoot operator
if (!(Test-Path $key)) { ssh-keygen -q -t ed25519 -N '' -C multica-vm-operator -f $key }
Copy-Item -LiteralPath "$key.pub" -Destination "$dir/operator.pub" -Force
if (!$SourceIso) {
    $SourceIso = Join-Path $dir ubuntu.iso
    if (!(Test-Path $SourceIso)) {
        curl.exe -fL --retry 3 --output "$SourceIso.part" $release.amd64ServerIso
        if ((Get-FileHash "$SourceIso.part").Hash -ne $release.sha256) { throw 'Ubuntu download checksum mismatch.' }
        Move-Item -LiteralPath "$SourceIso.part" -Destination $SourceIso
    }
}
$source = (Resolve-Path -LiteralPath $SourceIso).Path
if ((Get-FileHash -LiteralPath $source).Hash -ne $release.sha256) { throw 'Ubuntu ISO checksum mismatch.' }
$stamp = "$($release.sha256):$((Get-FileHash "$key.pub").Hash):$((Get-FileHash "$PSScriptRoot/make-media.py").Hash)"
if ((Test-Path "$dir/installer.iso") -and (Test-Path "$dir/media.json")) {
    $previous = Get-Content "$dir/media.json" -Raw | ConvertFrom-Json
    if ($previous.inputs -eq $stamp -and (Get-FileHash "$dir/installer.iso").Hash -eq $previous.sha256) { return }
}
docker build -q -t multica-local/iso-builder:26.04 -f "$PSScriptRoot/media.Dockerfile" $PSScriptRoot
if (Test-Path "$dir/installer.partial.iso") { Remove-Item -LiteralPath "$dir/installer.partial.iso" }
docker run --rm --network none --mount "type=bind,src=$source,dst=/source/ubuntu.iso,readonly" --mount "type=bind,src=$dir,dst=/media-out" multica-local/iso-builder:26.04
@{inputs=$stamp;sha256=(Get-FileHash "$dir/installer.iso").Hash} | ConvertTo-Json | Set-Content "$dir/media.json"

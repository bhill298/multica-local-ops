[CmdletBinding()]
param(
    [string]$ReleaseFile = (Join-Path $PSScriptRoot 'release.json'),
    [string]$IsoPath
)

$ErrorActionPreference = 'Stop'
$release = Get-Content -LiteralPath $ReleaseFile -Raw | ConvertFrom-Json
if ($release.series -notmatch '^\d{2}\.\d{2}$' -or
    $release.codename -notmatch '^[a-z]+$' -or
    $release.sha256 -notmatch '^[a-f0-9]{64}$') {
    throw 'Invalid release series, codename, or SHA-256 in the Ubuntu release file.'
}
if ($IsoPath -and (Get-FileHash -Algorithm SHA256 -LiteralPath $IsoPath).Hash -ne $release.sha256) {
    throw "ISO checksum differs from the release file: $IsoPath"
}
if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot "packages/$($release.codename).list") -PathType Leaf)) {
    throw "Missing package list for $($release.codename)."
}
$image = "ubuntu:$($release.series)"
docker run --pull always --rm --mount "type=bind,src=$PSScriptRoot,dst=/profile,readonly" $image bash -ec '. /etc/os-release; test "$VERSION_CODENAME" = "$1"; bash /profile/setup-packages.sh --check' check $release.codename
if ($LASTEXITCODE -ne 0) { throw "Package preflight failed for $image. See apt output above." }

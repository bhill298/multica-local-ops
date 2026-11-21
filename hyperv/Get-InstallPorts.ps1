param([Parameter(Mandatory)][string]$Name,[Parameter(Mandatory)][string]$Directory)
$ErrorActionPreference='Stop'
$profileDir=Split-Path ([IO.Path]::GetFullPath($Directory))
$relayFile=Join-Path $profileDir 'relay/relay.json'
$ownerFile=Join-Path $profileDir 'vm-name.txt'
$previous=if (Test-Path -LiteralPath $relayFile) { Get-Content -LiteralPath $relayFile -Raw | ConvertFrom-Json }
if (($previous -and $previous.name -ne $Name) -or
    ((Test-Path -LiteralPath $ownerFile) -and (Get-Content -LiteralPath $ownerFile -Raw).Trim() -ne $Name)) {
    throw 'Another VM owns this operator directory. Supply -Directory inside a separate profile folder.'
}
$ports=Get-Content -LiteralPath "$PSScriptRoot/dashboard-ports.json" -Raw | ConvertFrom-Json
$values=@(foreach ($key in 'home','daily','admin') {
    $value=$ports.$key
    if ($value -isnot [long] -and $value -isnot [int] -or $value -lt 1024 -or $value -gt 65535) { throw "Invalid dashboard port for $key." }
    $value
})
if (@($ports.PSObject.Properties).Count -ne 3 -or @($values | Sort-Object -Unique).Count -ne 3) {
    throw 'Set three distinct home, daily and admin ports in hyperv/dashboard-ports.json.'
}
$owned=if ($previous) {
    if ($previous.ports) { $previous.ports.home,$previous.ports.daily,$previous.ports.admin }
    else { 43130,43133,43230 }
}
foreach ($port in $values) {
    $probe=[Net.Sockets.TcpListener]::new([ipaddress]::Loopback,$port)
    try {
        $probe.ExclusiveAddressUse=$true
        $probe.Start()
    } catch {
        # Hyper-V can reserve a port without creating a visible TCP listener.
        $managed=$false
        if ($port -in $owned) {
            $listener=Get-NetTCPConnection -State Listen -LocalAddress 127.0.0.1 -LocalPort $port -ErrorAction SilentlyContinue
            if ($listener) {
                $process=Get-CimInstance Win32_Process -Filter "ProcessId=$($listener.OwningProcess)"
                $managed=$process.ExecutablePath -eq "$env:SystemRoot\System32\OpenSSH\ssh.exe" -and
                    $process.CommandLine -and $process.CommandLine.Contains("HostKeyAlias=$Name ") -and
                    $process.CommandLine.Contains("$profileDir/keys/operator") -and $process.CommandLine.Contains(' -NT ')
                if ($port -eq $ports.home -and $process.ExecutablePath -eq (Join-Path $profileDir 'portal/multica-portal.exe')) { $managed=$true }
            }
        }
        if (!$managed) { throw "Dashboard port $port is in use or reserved by Windows. Choose bindable ports in hyperv/dashboard-ports.json." }
    } finally {
        $probe.Stop()
    }
}
$ports

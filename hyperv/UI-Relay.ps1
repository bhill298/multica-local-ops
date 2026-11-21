param([Parameter(Mandatory)][string]$Config)
$ErrorActionPreference='Stop'
$options=Get-Content $Config -Raw | ConvertFrom-Json
$state=Get-Content $options.state -Raw | ConvertFrom-Json
if ($state.phase -ne 'installed' -or !$state.address) { exit 1 }
# Task Scheduler retries after disconnects. Never accept a changed guest host key.
$client="$env:SystemRoot/System32/OpenSSH/ssh.exe"
$ports=$options.ports
if (!$ports) { $ports=@{home=43130;daily=43133;admin=43230} } # Previously installed relay.json
$forwards=@('-L',"127.0.0.1:$($ports.home):127.0.0.1:43132",
            '-L',"127.0.0.1:$($ports.daily):127.0.0.1:43130",
            '-L',"127.0.0.1:$($ports.admin):127.0.0.1:43230")
& $client -NT -o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o "HostKeyAlias=$($options.name)" -o "UserKnownHostsFile=$($options.known)" -o ExitOnForwardFailure=yes -o ServerAliveInterval=10 -o ServerAliveCountMax=2 -i $options.key @forwards "multicaops@$($state.address)"
exit 1

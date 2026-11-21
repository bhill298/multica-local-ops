#Requires -Version 7.3
[CmdletBinding()]
param([string]$Name='Multica-Ubuntu',[string]$Directory="$env:LOCALAPPDATA/MulticaVM/media",
    [ValidateSet('Provision','Goal','UI','AdminUI','LoginCode','AdminCode','Shell','Auth','Put','PutExchange','Get','MapProjects','Status','Admin','AdminAuth','AdminStop')][string]$Action='Status',
    [ValidateSet('codex','claude','agy')][string]$Provider='codex',
    [string]$Path,[hashtable]$Goal,[ipaddress]$GuestAddress,[ValidateRange(1024,65535)][int]$LocalPort=43130,
    [switch]$PromptForLoginCode)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$true
if ($Name -notmatch '^[A-Za-z0-9-]{1,50}$') { throw 'Invalid VM name.' }
$state=Get-Content "$env:ProgramFiles/MulticaVM/$Name/vm.json" -Raw | ConvertFrom-Json
if ($state.phase -ne 'installed') { throw 'VM installation is incomplete. Inspect the provisioning log.' }
$operatorDir=Split-Path ([IO.Path]::GetFullPath($Directory))
$key=Join-Path $operatorDir keys/operator
$known=Join-Path $operatorDir known_hosts
$address=if ($GuestAddress) { $GuestAddress.IPAddressToString } else { $state.address }
if (!$address) { throw 'Guest address discovery pending. See the provisioning log or specify -GuestAddress.' }
$opts=@('-i',$key,'-o','IdentitiesOnly=yes','-o','BatchMode=yes','-o','ConnectTimeout=10','-o',"HostKeyAlias=$Name",'-o',"UserKnownHostsFile=$known",'-o','StrictHostKeyChecking=accept-new')
$target="multicaops@$address"
$compose='sudo docker compose -p multica-vm -f /var/lib/multica-local/compose.json'
switch ($Action) {
    Provision {
        $archive=Join-Path ([IO.Path]::GetTempPath()) ("multica-"+[guid]::NewGuid()+".tar")
        try {
            # Only versioned setup assets travel to the guest.
            $root=Split-Path $PSScriptRoot
            tar -cf $archive -C $root hyperv linux-worker linux-guest config/settings.json config/roles.json coordination-local.txt
            scp @opts $archive "${target}:setup.tar"
            $policy="$env:ProgramFiles/MulticaVM/$Name/kvm.json"
            $kvm='off'
            if ((Test-Path $policy) -and (Get-Content $policy -Raw | ConvertFrom-Json).enabled) { $kvm='on' }
            ssh @opts $target 'set -eu; sudo install -d -m 755 /opt/multica-local; sudo tar -xf setup.tar --no-same-owner -C /opt/multica-local; rm setup.tar; sudo bash /opt/multica-local/linux-guest/setup-packages.sh --install; sudo systemctl enable --now docker'
            $provision="sudo python3 /opt/multica-local/hyperv/guest.py --kvm $kvm"
            if ($PromptForLoginCode) {
                $code=Read-Host 'Initial daily dashboard code (six digits)' -MaskInput
                if ($code -cnotmatch '^[0-9]{6}$') { throw 'Enter a six-digit code.' }
                $code | ssh @opts $target "$provision --initial-code-stdin"
            } else {
                ssh @opts $target $provision
            }
        } finally { if (Test-Path $archive) { Remove-Item -LiteralPath $archive } }
    }
    Status { ssh @opts $target "$compose ps" }
    Goal { $Goal | ConvertTo-Json -Compress | ssh @opts $target 'sudo python3 /opt/multica-local/hyperv/new-goal.py' }
    MapProjects { & "$PSScriptRoot/Map-Projects.ps1" -Name $Name -Directory $Directory }
    Shell { ssh @opts -t $target }
    Auth {
        $authCmd=@{codex='codex login --device-auth';claude='claude auth login --claudeai';agy='agy --model gemini-3.8-flash-low'}[$Provider]
        ssh @opts -t $target "$compose exec $Provider $authCmd"
    }
    { $_ -in 'Put','PutExchange' } {
        $source=(Resolve-Path -LiteralPath $Path).Path
        $folder=if ($Action -eq 'Put') {'input'} else {'exchange'}
        scp @opts -r $source "${target}:/srv/multica/project/$folder/"
    }
    Get {
        if (!$Path -or !(Test-Path -LiteralPath $Path -PathType Container)) { throw 'Specify a local destination directory.' }
        scp @opts -r "${target}:/srv/multica/project/exchange/." $Path
    }
    { $_ -in 'UI','AdminUI' } {
        $remotePort=if ($Action -eq 'AdminUI') {43230} else {43130}
        if (!$PSBoundParameters.ContainsKey('LocalPort')) { $LocalPort=$remotePort }
        Write-Host "Open http://localhost:$LocalPort while this tunnel is running."
        ssh @opts -o ExitOnForwardFailure=yes -N -L "127.0.0.1:${LocalPort}:127.0.0.1:$remotePort" $target
    }
    { $_ -in 'LoginCode','AdminCode' } {
        $store=if ($Action -eq 'AdminCode') {'multica-owner-only'} else {'multica-local'}
        ssh @opts $target ("sudo python3 -c 'import json;print(json.load(open(`"/var/lib/{0}/credentials.json`"))[`"code`"])'" -f $store)
    }
    { $_ -in 'Admin','AdminAuth' } {
        $mode=if ($Action -eq 'Admin') { 'start' } else { 'auth' }
        $command="sudo bash /opt/multica-local/hyperv/admin.sh $mode"
        if ($PromptForLoginCode) { $command+=' --prompt-for-login-code' }
        ssh @opts -t $target $command
    }
    AdminStop { ssh @opts $target 'sudo bash /opt/multica-local/hyperv/admin.sh stop' }
}

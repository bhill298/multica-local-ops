#Requires -Version 7.3
[CmdletBinding()]
param([string]$Name='Multica-Ubuntu',[string]$Directory="$env:LOCALAPPDATA/MulticaVM/media",
    [ValidateSet('Provision','QuickStart','Goal','UI','AdminUI','LoginCode','AdminCode','Shell','Auth','SyncCodexAuth','Put','PutExchange','Get','MapProjects','Status','Admin','SetAdminProvider','AdminAuth','AdminStop')][string]$Action='Status',
    [ValidateSet('codex','claude','agy')][string]$Provider='codex',
    [string]$Path,[hashtable]$Goal,[ipaddress]$GuestAddress,[ValidateRange(1024,65535)][int]$LocalPort=43130,
    [switch]$PromptForLoginCode,[switch]$DailyOnly,[string]$Model,
    [ValidateSet('codex','claude','agy')][string]$AdminProvider,[switch]$UseInstallDefaults)
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
            $adminSetup='sudo python3 /opt/multica-local/hyperv/admin.py'
            $adminOptions=@{}
            if ($AdminProvider) { $adminOptions.provider=$AdminProvider }
            if ($Model) { $adminOptions.model=$Model }
            if ($PromptForLoginCode) {
                $code=Read-Host 'Initial admin dashboard code (six digits)' -MaskInput
                if ($code -cnotmatch '^[0-9]{6}$') { throw 'Enter a six-digit code.' }
                $adminOptions.initial_code=$code
            }
            if ($adminOptions.Count) {
                $adminOptions | ConvertTo-Json -Compress | ssh @opts $target "$adminSetup --setup-stdin"
            } else {
                ssh @opts $target $adminSetup
            }
        } finally { if (Test-Path $archive) { Remove-Item -LiteralPath $archive } }
    }
    Status { ssh @opts $target "$compose ps" }
    QuickStart {
        $logins=ssh @opts $target 'sudo python3 /opt/multica-local/hyperv/dashboard_logins.py' | ConvertFrom-Json
        $helper='./hyperv/Connect-Guest.ps1'
        if ($Name -ne 'Multica-Ubuntu') { $helper+=" -Name $Name" }
        if ($Directory -ne "$env:LOCALAPPDATA/MulticaVM/media") {
            $helper+=" -Directory '{0}'" -f ([IO.Path]::GetFullPath($Directory)).Replace("'","''")
        }
        $dailyPin=if ($logins.daily.pin) { $logins.daily.pin } else { "run $helper -Action LoginCode" }
        $adminPin=if ($logins.admin.pin) { $logins.admin.pin } else { "run $helper -Action AdminCode" }
        @"

Multica quick start
Open http://localhost:43130 in Windows and choose a workspace.

Daily dashboard    http://localhost:43130/user
Email              $($logins.daily.email)
PIN                $dailyPin
Open the dashboard, enter the email, request a code, then enter the PIN.
Sign in or renew a provider from Windows. Codex signs in once for both workers:
  $helper -Action Auth -Provider codex
  $helper -Action Auth -Provider claude
  $helper -Action Auth -Provider agy

VM admin dashboard http://localhost:43130/admin  (full Ubuntu access)
Worker             $($logins.admin.provider) / $($logins.admin.model)
Email              $($logins.admin.email)
PIN                $adminPin
Both instances and the VM admin worker start with Ubuntu.
For a Claude or Agy admin worker, sign in separately as the Ubuntu admin user:
  $helper -Action AdminAuth
"@
    }
    Goal { $Goal | ConvertTo-Json -Compress | ssh @opts $target 'sudo python3 /opt/multica-local/hyperv/new-goal.py' }
    MapProjects { & "$PSScriptRoot/Map-Projects.ps1" -Name $Name -Directory $Directory }
    Shell { ssh @opts -t $target }
    Auth {
        if ($Provider -eq 'codex' -and !$DailyOnly) {
            ssh @opts -t $target 'sudo bash /opt/multica-local/hyperv/codex-auth.sh login'
            return
        }
        $authCmd=@{codex='codex login --device-auth';claude='claude auth login --claudeai';agy='agy --model gemini-3.8-flash-low'}[$Provider]
        ssh @opts -t $target "$compose exec $Provider $authCmd"
    }
    SyncCodexAuth { ssh @opts $target 'sudo bash /opt/multica-local/hyperv/codex-auth.sh copy' }
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
        if (!$PSBoundParameters.ContainsKey('LocalPort')) {
            $pathName=if ($Action -eq 'AdminUI') { 'admin' } else { 'user' }
            Write-Output "Open http://localhost:43130/$pathName"
            return
        }
        $remotePort=if ($Action -eq 'AdminUI') {43230} else {43130}
        $browserHost=if ($Action -eq 'AdminUI') { '127.0.0.1' } else { 'localhost' }
        Write-Host "Open http://${browserHost}:$LocalPort while this tunnel is running."
        ssh @opts -o ExitOnForwardFailure=yes -N -L "127.0.0.1:${LocalPort}:127.0.0.1:$remotePort" $target
    }
    { $_ -in 'LoginCode','AdminCode' } {
        $store=if ($Action -eq 'AdminCode') {'multica-owner-only'} else {'multica-local'}
        ssh @opts $target ("sudo python3 -c 'import json;print(json.load(open(`"/var/lib/{0}/credentials.json`"))[`"code`"])'" -f $store)
    }
    AdminAuth {
        $command='sudo python3 /opt/multica-local/hyperv/admin_provider.py auth'
        if ($PSBoundParameters.ContainsKey('Provider')) { $command+=" --provider $Provider" }
        ssh @opts -t $target $command
    }
    SetAdminProvider {
        $selection=@{}
        if ($UseInstallDefaults) {
            if ($PSBoundParameters.ContainsKey('Provider') -or $PSBoundParameters.ContainsKey('Model')) {
                throw 'UseInstallDefaults cannot be combined with Provider or Model.'
            }
            $selection.use_install_defaults=$true
        } elseif ($PSBoundParameters.ContainsKey('Provider')) {
            $selection.provider=$Provider
        } else { throw 'Specify -Provider codex, claude or agy, or -UseInstallDefaults.' }
        if ($PSBoundParameters.ContainsKey('Model')) { $selection.model=$Model }
        $selection | ConvertTo-Json -Compress | ssh @opts $target 'sudo python3 /opt/multica-local/hyperv/admin.py --select-stdin'
    }
    Admin {
        $command='sudo bash /opt/multica-local/hyperv/admin.sh start'
        if ($PromptForLoginCode) { $command+=' --prompt-for-login-code' }
        ssh @opts -t $target $command
    }
    AdminStop { ssh @opts $target 'sudo bash /opt/multica-local/hyperv/admin.sh stop' }
}

#Requires -Version 7.3
[CmdletBinding()]
param([ValidatePattern('^[A-Za-z0-9-]{1,50}$')][string]$Name='Multica-Ubuntu',
    [string]$Directory="$env:LOCALAPPDATA/MulticaVM/media",[switch]$Apply,[switch]$KeepDisk)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$true
$Directory=[IO.Path]::GetFullPath($Directory)
$profileDir=Split-Path $Directory
$root=Join-Path $env:ProgramFiles "MulticaVM/$Name"
$relayFile=Join-Path $profileDir relay/relay.json
$ownerFile=Join-Path $profileDir vm-name.txt
$pending=Join-Path $profileDir "$Name-uninstall.json"
$resume=if (Test-Path -LiteralPath $pending){Get-Content -LiteralPath $pending -Raw | ConvertFrom-Json}
if ($resume -and ($resume.name -ne $Name -or $resume.directory -ne $Directory)){throw 'Wrong operator uninstall receipt.'}
$owner=if (Test-Path $ownerFile) {(Get-Content $ownerFile -Raw).Trim()}
$relay=if (Test-Path $relayFile) {Get-Content $relayFile -Raw | ConvertFrom-Json}
if (!$owner -and !$relay -and !$resume -and !(Test-Path "$root/vm.json")) {Write-Output "No registered installation of $Name at this location.";return}
if ((!$owner -and !$relay -and !$resume) -or ($owner -and $owner -ne $Name) -or ($relay -and $relay.name -ne $Name)) {throw 'Specify the operator directory belonging to this installation.'}
$manifest=if(Test-Path "$root/portal/install.json"){Get-Content "$root/portal/install.json" -Raw | ConvertFrom-Json}
if ($manifest -and $manifest.directory -ne $Directory){throw 'Operator directory differs from the protected installation record.'}
$state=if (Test-Path "$root/vm.json"){Get-Content "$root/vm.json" -Raw | ConvertFrom-Json}
if (!$state -and !(Test-Path $pending)){throw 'No owned VM or interrupted uninstall found.'}
$choice=if ($KeepDisk){'keep the merged system VHDX and operator SSH keys'}else{'delete the system VHDX, including guest containers, databases, logins and project files'}
Write-Output "Uninstall $Name and $choice. Remove its scheduled tasks, hostname block, update exports, checkpoints, mapped project drive, portal and generated media. Operator profile: $profileDir."
if (!$Apply) {Write-Output 'Preview only. Add -Apply to uninstall. Copy any work or update exports you want to keep first.';return}
foreach ($p in $profileDir,$Directory,(Join-Path $profileDir keys),(Join-Path $profileDir relay),(Join-Path $profileDir portal)) {
    for ($item=Get-Item -LiteralPath $p -ErrorAction SilentlyContinue; $item; $item=$item.Parent) {
        if ($item.Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)){throw "Refusing linked operator path: $($item.FullName)"}
    }
}
if ($state) {
    $arg='-NoProfile -NonInteractive -File "{0}" -Name {1} -Directory "{2}" -VMId {3}' -f "$PSScriptRoot/hyperv/Uninstall-Host.ps1",$Name,$Directory,([guid]$state.id)
    if ($KeepDisk){$arg+=' -KeepDisk'}
    @{id=$state.id;name=$Name;directory=$Directory;keep=[bool]$KeepDisk} | ConvertTo-Json | Set-Content $pending
    $p=Start-Process (Get-Process -Id $PID).Path -WindowStyle Hidden -Verb RunAs -ArgumentList $arg -PassThru -Wait
    if ($p.ExitCode){throw 'Elevated uninstall stopped. Review VM disks, backup/operation locks and managed hosts block before retrying.'}
} elseif ((Get-Content $pending -Raw|ConvertFrom-Json).keep -ne [bool]$KeepDisk) {throw 'Resume with the original disk choice.'}
$record=Join-Path $profileDir "$Name-project-drive.json"
if (Test-Path $record) {
    $drive=Get-Content $record -Raw | ConvertFrom-Json
    if ($drive.local -match '^[D-Z]:$' -and $drive.remote -match '^\\\\[0-9.]+\\MulticaProjects$') {
        $mapping=Get-SmbMapping -LocalPath $drive.local -ErrorAction SilentlyContinue
        if ($mapping -and $mapping.RemotePath -eq $drive.remote){Remove-SmbMapping -InputObject $mapping -Force}
    }
}
foreach ($proc in Get-CimInstance Win32_Process -Filter "Name='ssh.exe'") {
    if ($proc.ExecutablePath -eq "$env:SystemRoot\System32\OpenSSH\ssh.exe" -and $proc.CommandLine -and
        $proc.CommandLine.Contains("HostKeyAlias=$Name ") -and $proc.CommandLine.Contains("$profileDir/keys/operator") -and $proc.CommandLine.Contains(' -NT ')){
        Stop-Process -Id $proc.ProcessId -ErrorAction SilentlyContinue
    }
}
function Clear-Files([string]$Folder,[string[]]$Names) {
    if (!(Test-Path -LiteralPath $Folder)){return}
    if ((Get-Item -LiteralPath $Folder).Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)){throw "Refusing linked folder: $Folder"}
    foreach ($leaf in $Names) {
        $path=Join-Path $Folder $leaf
        if (Test-Path -LiteralPath $path -PathType Leaf) {Remove-Item -LiteralPath $path -Force}
    }
    if (!(Get-ChildItem -LiteralPath $Folder -Force)){Remove-Item -LiteralPath $Folder}
}
$keyPath=Join-Path $profileDir keys/operator.pub
$folders=@($Directory)
if (Test-Path $keyPath) {
    $hash=(Get-FileHash $keyPath).Hash
    foreach ($extra in Get-ChildItem -LiteralPath $profileDir -Directory -Filter 'media-*') {
        if (!$extra.Attributes.HasFlag([IO.FileAttributes]::ReparsePoint) -and (Test-Path "$($extra.FullName)/media.json") -and (Test-Path "$($extra.FullName)/operator.pub") -and (Get-FileHash "$($extra.FullName)/operator.pub").Hash -eq $hash){$folders+=$extra.FullName}
    }
}
foreach ($folder in ($folders | Sort-Object -Unique)) {
    if (!(Test-Path "$folder/media.json")){continue}
    $media=Get-Content "$folder/media.json" -Raw | ConvertFrom-Json
    $files=@('media.json','operator.pub','ubuntu.iso.part','installer.partial.iso')
    if ((Test-Path "$folder/ubuntu.iso") -and (Get-FileHash "$folder/ubuntu.iso").Hash -eq $media.inputs.Split(':')[0]) {$files+='ubuntu.iso'}
    if ((Test-Path "$folder/installer.iso") -and (Get-FileHash "$folder/installer.iso").Hash -eq $media.sha256) {$files+='installer.iso'}
    Clear-Files $folder $files
}
& "$PSScriptRoot/hyperv/Remove-PortalShortcut.ps1" -Name $Name -ProfileDir $profileDir
Clear-Files "$profileDir/portal/build" @('multica-portal.new.exe')
Clear-Files "$profileDir/portal" @('multica-portal.exe','multica-portal.new.exe','portal.json','operator.key','open-management.html')
Clear-Files "$profileDir/relay" @('UI-Relay.ps1','relay.json','relay.vbs','Map-Projects.ps1','projects.vbs')
if (!$KeepDisk){Clear-Files "$profileDir/keys" @('operator','operator.pub')}
$remove=@("$Name-project-drive.json",'vm-name.txt')
if (!$KeepDisk){$remove+=@('known_hosts','known_hosts.old')}
$remove+="$Name-uninstall.json"
Clear-Files $profileDir $remove
$other=@(Get-ChildItem -Path "$env:ProgramFiles/MulticaVM/*/vm.json" -ErrorAction SilentlyContinue)
if (!$other -and (Get-Command docker -ErrorAction SilentlyContinue)) {
    try {
        $endpoint=docker context inspect --format '{{.Endpoints.docker.Host}}'
        if ($endpoint -like 'npipe:*' -and !$env:DOCKER_HOST) {
            $image='multica-local/iso-builder:26.04'
            if ((docker image ls --format '{{.Repository}}:{{.Tag}}') -contains $image) {
                if (!(docker ps -aq --filter "ancestor=$image")) {docker image rm $image} else {Write-Warning 'Another container uses the ISO builder. Its image was kept.'}
            }
        }
    } catch {Write-Warning 'Docker Desktop was unavailable. If present, remove the unused multica-local/iso-builder:26.04 image when Docker is running.'}
}
if ($KeepDisk){Write-Output "Kept $Name-system.vhdx in the Hyper-V disk folder and the operator key under $profileDir/keys."}
Write-Output "Uninstalled $Name."

#Requires -Version 7.3
[CmdletBinding()]
param([string]$Name='Multica-Ubuntu',[string]$SourceIso,
    [string]$Directory="$env:LOCALAPPDATA/MulticaVM/media",
    [int]$Processors,[int]$MaximumGiB,[ValidateRange(40,2048)][int]$DiskGiB=128,
    [ValidateRange(1,52)][int]$Keep=4,[switch]$SkipProjectDrive,
    [ValidateSet('On','Off')][string]$NestedVirtualization,[switch]$PromptForLoginCode)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$true
if (!$IsWindows -or $Name -notmatch '^[A-Za-z0-9-]{1,50}$') { throw 'Run on Windows with a valid VM name.' }
foreach ($command in 'docker','ssh','scp','ssh-keygen','tar','Get-VM') {
    if (!(Get-Command $command -ErrorAction SilentlyContinue)) { throw "Install $command before provisioning. Hyper-V requires a supported Windows edition and virtualization enabled in firmware." }
}
if ((Get-Service vmms -ErrorAction SilentlyContinue).Status -ne 'Running') { throw 'Enable Hyper-V with management tools, enable firmware virtualization and restart Windows.' }
if ([GC]::GetGCMemoryInfo().TotalAvailableMemoryBytes -lt 15GB) { throw 'This deployment needs a host with at least 16 GiB RAM.' }
& "$PSScriptRoot/hyperv/Prepare-Media.ps1" -Directory $Directory -SourceIso $SourceIso
$media=(Resolve-Path "$Directory/installer.iso").Path
$hostScript=(Resolve-Path "$PSScriptRoot/hyperv/Install-Host.ps1").Path
$arguments='-NoProfile -File "{0}" -Media "{1}" -Name {2} -Processors {3} -MaximumGiB {4} -DiskGiB {5} -Keep {6}' -f $hostScript,$media,$Name,$Processors,$MaximumGiB,$DiskGiB,$Keep
if ($NestedVirtualization) { $arguments+=" -NestedVirtualization $NestedVirtualization" }
$proc=Start-Process (Get-Process -Id $PID).Path -WindowStyle Hidden -Verb RunAs -ArgumentList $arguments -PassThru -Wait
if ($proc.ExitCode) { throw "Hyper-V setup failed. See $env:ProgramFiles/MulticaVM/$Name/provision.log." }
& "$PSScriptRoot/hyperv/Connect-Guest.ps1" -Name $Name -Directory $Directory -Action Provision -PromptForLoginCode:$PromptForLoginCode
& "$PSScriptRoot/hyperv/Install-Relay.ps1" -Name $Name -Directory $Directory -SkipProjectDrive:$SkipProjectDrive
if (!$SkipProjectDrive) { & "$PSScriptRoot/hyperv/Connect-Guest.ps1" -Name $Name -Directory $Directory -Action MapProjects }
& "$PSScriptRoot/hyperv/Connect-Guest.ps1" -Name $Name -Directory $Directory -Action QuickStart

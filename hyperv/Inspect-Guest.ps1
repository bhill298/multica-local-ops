#Requires -RunAsAdministrator
#Requires -Version 7.2
param([string]$Name='Multica-Ubuntu')
$ErrorActionPreference='Stop'
if ($Name -notmatch '^[A-Za-z0-9-]{1,50}$') { throw 'Invalid VM name.' }
$root=Join-Path $env:ProgramFiles "MulticaVM/$Name"
Start-Transcript -Path "$root/inspect.log" -Force | Out-Null
$state=Get-Content "$root/vm.json" -Raw | ConvertFrom-Json
$vm=Get-VM -Id $state.id
$nic=Get-VMNetworkAdapter -VM $vm
@{name=$vm.Name;id=$vm.Id;state="$($vm.State)";uptime=$vm.Uptime.ToString();cpu=$vm.CPUUsage;
    status=$vm.Status; addresses=$nic.IPAddresses; mac=$nic.MacAddress; policies=@(Get-VMNetworkAdapterExtendedAcl -VMNetworkAdapter $nic).Count;
    checkpoints=@(Get-VMSnapshot -VM $vm | Select-Object Name,Id,CreationTime)} |
    ConvertTo-Json -Depth 3 | Set-Content "$root/inspection.json"
if ($vm.State -eq 'Running') {
    $vs=Get-CimInstance -Namespace root/virtualization/v2 -ClassName Msvm_ComputerSystem -Filter "Name='$($vm.Id)'"
    $setting=Get-CimAssociatedInstance -InputObject $vs -Association Msvm_SettingsDefineState -ResultClassName Msvm_VirtualSystemSettingData | Select-Object -First 1
    $svc=Get-CimInstance -Namespace root/virtualization/v2 -ClassName Msvm_VirtualSystemManagementService
    $result=Invoke-CimMethod -InputObject $svc -MethodName GetVirtualSystemThumbnailImage -Arguments @{TargetSystem=$setting;WidthPixels=[uint16]800;HeightPixels=[uint16]600}
    Write-Host "Console result $($result.ReturnValue), bytes $($result.ImageData.Length)"
    if ($result.ReturnValue -eq 0 -and $result.ImageData.Length -in 960000,960004) {
        # Hyper-V returns a top-down RGB565 buffer. Use a BMP with explicit channel masks.
        $bytes=[IO.BinaryWriter]::new([IO.File]::Create("$root/console.bmp"))
        try {
            $bytes.Write([byte[]](66,77))
            foreach($value in @(960066,0,66,40,800,-600,1048577,3,960000,0,0,0,0,63488,2016,31)) {$bytes.Write([int]$value)}
            $bytes.Write([byte[]]$result.ImageData,($result.ImageData.Length-960000),960000)
        } finally {$bytes.Dispose()}
    }
}

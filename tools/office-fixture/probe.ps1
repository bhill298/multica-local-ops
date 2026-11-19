#Requires -Version 7.2
param([ValidateSet('Both','Excel','Word')][string]$TargetApp='Both')
$ErrorActionPreference='Stop'
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$artifactRoot=Join-Path $PSScriptRoot 'output'
if(Test-Path -LiteralPath $artifactRoot){
 if((Get-Item -LiteralPath $artifactRoot).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Output root must not be a link or junction'}
}else{New-Item -ItemType Directory -Path $artifactRoot -ErrorAction Stop|Out-Null}
$output=Join-Path $artifactRoot ('run-'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $output -ErrorAction Stop|Out-Null
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class OfficeProbeWindow {
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hwnd,out uint pid);
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
}
'@
function AppPid($hwnd){$id=[uint32]0;[void][OfficeProbeWindow]::GetWindowThreadProcessId([IntPtr]$hwnd,[ref]$id);return [int]$id}
function ForegroundPid {return AppPid ([OfficeProbeWindow]::GetForegroundWindow())}
$results=@()
foreach($kind in $(if($TargetApp -eq 'Both'){@('Excel','Word')}else{@($TargetApp)})){
 $existing=@(Get-Process -Name $(if($kind -eq 'Excel'){'EXCEL'}else{'WINWORD'}) -ErrorAction SilentlyContinue|ForEach-Object Id)
 $app=$null;$doc=$null;$sheet=$null;$ownedPid=$null
 $record=[ordered]@{app=$kind;started_at=[DateTimeOffset]::Now.ToString('o');existing_pids=$existing;pass=$false;test_was_foreground=$false}
 try{
  if($kind -eq 'Word' -and $existing.Count){throw 'Existing Word process present; skipping to avoid sharing a user instance'}
  $app=New-Object -ComObject "$kind.Application"
  if($kind -eq 'Word'){
   $doc=$app.Documents.Add([Type]::Missing,$false,0,$false)
   $ownedPid=AppPid $doc.ActiveWindow.Hwnd
  }else{$ownedPid=AppPid $app.Hwnd}
  if($ownedPid -in $existing){$ownedPid=$null;throw 'COM returned a pre-existing application; refusing to use it'}
  $app.Visible=$false
  $record.owned_pid=$ownedPid
  $record.test_was_foreground=(ForegroundPid) -eq $ownedPid
  if($kind -eq 'Excel'){
   $app.DisplayAlerts=$false;$app.EnableEvents=$false
   $doc=$app.Workbooks.Add();$sheet=$doc.Worksheets.Item(1)
   $sheet.Range('A1').Value2='Multica background Excel proof'
   $sheet.Range('A2').Value2=19;$sheet.Range('A3').Value2=23;$sheet.Range('A4').Formula='=SUM(A2:A3)'
   $app.Calculate();if($sheet.Range('A4').Value2 -ne 42){throw 'Unexpected Excel calculation'}
   $path=Join-Path $output 'mcp-proof.xlsx';$doc.SaveAs($path,51)
   $record.calculated_value=$sheet.Range('A4').Value2
   $doc.Close($false);[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($sheet);$sheet=$null
   [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($doc);$doc=$null
   $doc=$app.Workbooks.Open($path,0,$true)
   $sheet=$doc.Worksheets.Item(1)
   if($sheet.Range('A1').Value2 -ne 'Multica background Excel proof' -or $sheet.Range('A4').Value2 -ne 42){throw 'Reopened Excel values differ'}
   $record.reopen_verified=$true;$record.file=$path
  }else{
   $app.DisplayAlerts=0
   $doc.Content.Text="Multica background Word proof`r`nCreated through the application API without input injection."
   $path=Join-Path $output 'mcp-proof.docx';$doc.SaveAs2($path,16)
   $pdf=Join-Path $output 'mcp-proof.pdf';$doc.ExportAsFixedFormat($pdf,17)
   if($doc.Content.Text -notlike 'Multica background Word proof*'){throw 'Word text differs'}
   $record.file=$path;$record.pdf=$pdf;$record.text_verified=$true
  }
  $record.test_was_foreground=$record.test_was_foreground -or ((ForegroundPid) -eq $ownedPid)
  $record.visible=$app.Visible
  if($app.Visible -or $record.test_was_foreground){throw 'Test instance unexpectedly visible or foreground'}
  $record.pass=$true
 }catch{$record.error=$_.Exception.Message}
 finally{
  if($ownedPid){
   if($doc){try{$doc.Close(0)}catch{}}
   if($app){try{$app.Quit()}catch{}}
  }
  foreach($com in @($sheet,$doc,$app)){if($com -and [Runtime.InteropServices.Marshal]::IsComObject($com)){try{[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($com)}catch{}}}
  [GC]::Collect();[GC]::WaitForPendingFinalizers()
  $record.finished_at=[DateTimeOffset]::Now.ToString('o')
  $results+=([pscustomobject]$record)
  $results|ConvertTo-Json -Depth 8|Set-Content (Join-Path $output 'result.json')
 }
}
$results|ConvertTo-Json -Depth 8
if(@($results|Where-Object {-not $_.pass}).Count){exit 1}

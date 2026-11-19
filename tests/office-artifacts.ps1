#Requires -Version 5.1
param([Parameter(Mandatory)][string]$ResultFile)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$records=@(Get-Content -LiteralPath $ResultFile -Raw|ConvertFrom-Json)
if($records.Count -ne 2 -or @($records|Where-Object{-not $_.pass -or $_.visible -or $_.test_was_foreground}).Count){throw 'Probe did not report hidden owned instances'}
function Read-ZipEntry([string]$Path,[string]$Entry){
 $zip=[IO.Compression.ZipFile]::OpenRead($Path)
 try{
  $item=$zip.GetEntry($Entry)
  if(-not $item){throw 'Missing Office XML entry'}
  $reader=[IO.StreamReader]::new($item.Open())
  try{return $reader.ReadToEnd()}finally{$reader.Dispose()}
 }finally{$zip.Dispose()}
}
$excel=$records|Where-Object app -eq 'Excel'
$word=$records|Where-Object app -eq 'Word'
[xml]$sheet=Read-ZipEntry $excel.file 'xl/worksheets/sheet1.xml'
$cell=$sheet.SelectSingleNode("//*[local-name()='c' and @r='A4']")
if($cell.f -ne 'SUM(A2:A3)' -or $cell.v -ne '42'){throw 'Saved formula or cached result differs'}
$document=Read-ZipEntry $word.file 'word/document.xml'
if($document -notlike '*Multica background Word proof*'){throw 'Saved Word text differs'}
$pdf=[IO.File]::ReadAllBytes($word.pdf)
if($pdf.Length -lt 1000 -or [Text.Encoding]::ASCII.GetString($pdf,0,5) -ne '%PDF-'){throw 'Invalid PDF export'}
foreach($record in $records){
 if($record.owned_pid -in $record.existing_pids){throw 'Probe used a pre-existing process'}
}
@{verified=$true;formula='SUM(A2:A3)';cached_value=42;word_text=$true;pdf_header=$true}|ConvertTo-Json -Compress

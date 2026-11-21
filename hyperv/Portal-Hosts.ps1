function Set-PortalHosts([guid]$Id,[string]$Prefix,[switch]$Remove,[string]$Path="$env:SystemRoot/System32/drivers/etc/hosts") {
    if ($Prefix -notmatch '^[a-z0-9][a-z0-9-]{0,49}$') { throw 'Invalid portal hostname prefix.' }
    $encoding=[Text.Encoding]::Latin1
    $old=$encoding.GetString([IO.File]::ReadAllBytes($Path))
    if ($old.Contains([char]0)) { throw 'The hosts file uses a wide-character encoding. Save it as UTF-8 or ANSI before installing local hostnames.' }
    $start="# BEGIN Multica $Id"
    $end="# END Multica $Id"
    $previousNames=@("$Prefix.localhost","$Prefix-user.localhost","$Prefix-admin.localhost")
    $names=@("$Prefix.lan","$Prefix-user.lan","$Prefix-admin.lan")+$previousNames
    $lines=@($start,"127.0.0.1 $($names -join ' ')",$end)
    $newline=if ($old.Contains("`r`n")) {"`r`n"} else {"`n"}
    $block=($lines -join $newline)+$newline
    $previousBlock=(@($start,"127.0.0.1 $($previousNames -join ' ')",$end) -join $newline)+$newline
    $index=$old.IndexOf($start,[StringComparison]::Ordinal)
    if ($index -ge 0) {
        $existing=if ($old.Substring($index).StartsWith($block)) {$block} elseif ($old.Substring($index).StartsWith($previousBlock)) {$previousBlock}
        if (($index -gt 0 -and $old[$index-1] -ne "`n") -or !$existing -or $old.LastIndexOf($start) -ne $index) {
            throw "The managed hosts block was edited. Inspect $Path."
        }
        $rest=$old.Remove($index,$existing.Length)
    } else { $rest=$old }
    if ($Remove) { $next=$rest }
    else {
        foreach ($line in ($rest -split '\r?\n')) {
            $words=@(($line.Split('#')[0].Trim() -split '\s+') | Select-Object -Skip 1)
            if ($words | Where-Object { $_ -in $names }) { throw 'A Multica hostname already exists outside the managed hosts block.' }
        }
        if ($index -ge 0) { $next=$rest.Insert($index,$block) }
        else {
            if ($rest.Length -and !$rest.EndsWith("`n")) { $rest+=$newline }
            $next=$rest+$block
        }
    }
    if ($next -ceq $old) { return }
    $tmp=Join-Path (Split-Path $Path) ("multica-hosts-"+[guid]::NewGuid()+".tmp")
    try {
        [IO.File]::WriteAllBytes($tmp,$encoding.GetBytes($next))
        if ($encoding.GetString([IO.File]::ReadAllBytes($Path)) -cne $old) {throw 'Hosts file changed during installation. Retry.'}
        [IO.File]::Replace($tmp,$Path,[NullString]::Value)
    } finally { if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp } }
}

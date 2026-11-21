# Run on Windows so the probe uses the same named portal routes as the browser.
function Get-LoginFailure([Net.Http.HttpClient]$Client,[uri]$Url) {
    $next=$Url
    try {
        for ($hop=0;$hop -le 5;$hop++) {
            $response=$Client.GetAsync($next,[Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
            try {
                if ($response.IsSuccessStatusCode) {return}
                $code=[int]$response.StatusCode
                $location=$response.Headers.Location
                if ($code -notin 301,302,303,307,308 -or !$location) {return "HTTP $code at $($next.AbsolutePath)"}
                $next=[uri]::new($next,$location)
                if ($next.Scheme -ne $Url.Scheme -or $next.Authority -ne $Url.Authority) {
                    return "HTTP $code redirected to a different origin ($($next.GetLeftPart('Authority')))"
                }
            } finally {$response.Dispose()}
        }
        return 'Exceeded five same-origin redirects'
    } catch {return $_.Exception.GetBaseException().Message}
}

function Get-DashboardHealth($Config,[int]$RetrySeconds) {
    $suffix=if ($Config.webPort -ne 80){":$($Config.webPort)"}
    $results=@(foreach ($role in 'user','admin') {
        [pscustomobject]@{Url="http://$($Config.prefix)-$role.lan$suffix/login";Healthy=$false;Failure=''}
    })
    $handler=[Net.Http.HttpClientHandler]::new()
    $handler.AllowAutoRedirect=$false
    $handler.UseProxy=$false
    $client=[Net.Http.HttpClient]::new($handler)
    $client.Timeout=[TimeSpan]::FromSeconds(4)
    try {
        $deadline=[datetime]::UtcNow.AddSeconds($RetrySeconds)
        do {
            foreach ($result in $results) {
                if ($result.Healthy){continue}
                $result.Failure=Get-LoginFailure $client $result.Url
                $result.Healthy=!$result.Failure
            }
            if ($false -notin $results.Healthy -or [datetime]::UtcNow -ge $deadline){break}
            Start-Sleep 2
        } while ($true)
    } finally {$client.Dispose()}
    return $results
}

function Compare-DashboardHealth($Before,$After,[string]$Tag,[string]$BackupRoot) {
    $regressions=@()
    $existing=@()
    foreach ($result in $After) {
        if ($result.Healthy){continue}
        $prior=$Before | Where-Object Url -eq $result.Url
        $reason="$($result.Url): $($result.Failure)"
        if ($prior.Healthy){$regressions+=$reason} else {$existing+="$reason (before update: $($prior.Failure))"}
    }
    $message="Backup receipts: $BackupRoot."
    if ($existing){$message+=" Already unavailable before update: $($existing -join '; ')."}
    if ($regressions){throw "Upgrade applied ($Tag); Windows dashboard verification failed: $($regressions -join '; '). $message"}
    if (!$existing){$message+=' Both Windows login URLs responded.'}
    return "Installed $Tag. $message"
}

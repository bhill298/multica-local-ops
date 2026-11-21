$ErrorActionPreference='Stop'
. "$PSScriptRoot/../hyperv/Dashboard-Health.ps1"
$config=@{prefix='multica-test';webPort=8042}
$userUrl='http://multica-test-user.localhost:8042/login'
$adminUrl='http://multica-test-admin.localhost:8042/login'
$failures=@{$userUrl=@($null);$adminUrl=@('HTTP 503 at /login')}
function Get-LoginFailure($Client,$Url) {
    $series=$failures[$Url]
    if ($series.Count -gt 1){$failures[$Url]=@($series[1..($series.Count-1)])}
    return $series[0]
}
$before=Get-DashboardHealth $config 0
$after=Get-DashboardHealth $config 0
$msg=Compare-DashboardHealth $before $after 'test-release' 'test-backups'
if (!$msg.Contains('Already unavailable') -or !$msg.Contains($adminUrl)){throw 'Pre-existing outage must be reported without failing the upgrade.'}
$failures[$userUrl]=@('HTTP 502 at /login',$null)
$failures[$adminUrl]=@($null)
$after=Get-DashboardHealth $config 5
if ($false -in $after.Healthy){throw 'Transient dashboard startup failure did not recover.'}
$failures[$userUrl]=@('HTTP 503 at /login')
$after=Get-DashboardHealth $config 0
$msg=''
try { Compare-DashboardHealth $before $after 'test-release' 'test-backups' } catch { $msg=$_.Exception.Message }
foreach ($detail in 'Upgrade applied',$userUrl,'HTTP 503','test-backups') {
    if (!$msg.Contains($detail)){throw "Missing regression diagnostic: $detail"}
}

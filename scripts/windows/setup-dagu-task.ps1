$ErrorActionPreference = "Stop"
$command = Get-Command "dagu.cmd" -ErrorAction SilentlyContinue
if (-not $command) {
    $command = Get-Command "dagu.exe" -ErrorAction SilentlyContinue
}
if (-not $command) {
    Write-Host "dagu is not installed, skipping."
    return
}

$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit ([TimeSpan]::Zero) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew -Hidden
$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless cmd.exe /d /s /c `"`"$($command.Source)`" start-all`""
Register-ScheduledTask -TaskName "dagu - Start Service" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null

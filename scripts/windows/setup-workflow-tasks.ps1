$ErrorActionPreference = "Stop"
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit ([TimeSpan]::Zero) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew -Hidden

foreach ($tool in @("dagu", "n8n")) {
    $command = Get-Command "$tool.cmd" -ErrorAction SilentlyContinue
    if (-not $command) {
        $command = Get-Command "$tool.exe" -ErrorAction SilentlyContinue
    }
    if (-not $command) {
        Write-Host "$tool is not installed, skipping."
        continue
    }
    $arguments = if ($tool -eq "dagu") { "start-all" } else { "start" }
    $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless cmd.exe /d /s /c `"`"$($command.Source)`" $arguments`""
    Register-ScheduledTask -TaskName "$tool - Start Service" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
}

$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -Hidden

$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless powershell -Command `"podman machine start`""
$taskName = "Podman - Start Machine"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

$action = New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"ttyd -p 4090 -t fontSize=20 --writable -w (Resolve-Path -Path '~') pwsh`""
# To debug above action, uncomment and use below line:
# Start-Process -FilePath $action.Execute -ArgumentList $action.Arguments

$taskName = "ttyd - pwsh"
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force

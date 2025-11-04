$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -Hidden

$scriptPath = "$env:USERPROFILE/.ttyd/scripts/visual-studio-launcher.ps1"
$action = New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"ttyd -p 4090 -t fontSize=20 -t disableLeaveAlert=true --writable -w . pwsh -NoProfile -File `"`"$scriptPath`"`" `""
# To debug above action, uncomment and use below line:
# Start-Process -FilePath $action.Execute -ArgumentList $action.Arguments
$taskName = "ttyd - Visual Studio Launcher"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force

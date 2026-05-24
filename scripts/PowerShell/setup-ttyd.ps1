$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -Hidden
$port = 4090

$scriptPath = "$env:USERPROFILE/.ttyd/scripts/visual-studio-launcher.nu"
$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless nu -c `"ttyd -p $port -t fontSize=20 -t disableLeaveAlert=true --writable -w . nu '$scriptPath'`""
$port++
$taskName = "ttyd - Visual Studio Launcher"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

$scriptPath = "$env:USERPROFILE/.ttyd/scripts/terminal-launcher.nu"
$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless nu -c `"ttyd -p $port -t fontSize=20 -t disableLeaveAlert=true --writable -w . nu '$scriptPath'`""
$port++
$taskName = "ttyd - Terminal Launcher"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

$scriptPath = "$env:USERPROFILE/.ttyd/scripts/editor-launcher.nu"
$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless nu -c `"ttyd -p $port -t fontSize=20 -t disableLeaveAlert=true --writable -w . nu '$scriptPath'`""
$port++
$taskName = "ttyd - Editor Launcher"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

Write-Host "Done. ttyd services will start at next login." -ForegroundColor Green
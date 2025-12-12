$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -Hidden
$port = 4090

$scriptPath = "$env:USERPROFILE/.ttyd/scripts/visual-studio-launcher.ps1"
$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless pwsh -Command `"ttyd -p $port -t fontSize=20 -t disableLeaveAlert=true --writable -w . pwsh -NoProfile -File '$scriptPath'`""
$port++
$taskName = "ttyd - Visual Studio Launcher"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

$scriptPath = "$env:USERPROFILE/.ttyd/scripts/terminal-launcher.ps1"
$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless pwsh -Command `"ttyd -p $port -t fontSize=20 -t disableLeaveAlert=true --writable -w . pwsh -NoProfile -File '$scriptPath'`""
$port++
$taskName = "ttyd - Terminal Launcher"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

$scriptPath = "$env:USERPROFILE/.ttyd/scripts/editor-launcher.ps1"
$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless pwsh -Command `"ttyd -p $port -t fontSize=20 -t disableLeaveAlert=true --writable -w . pwsh -NoProfile -File '$scriptPath'`""
$port++
$taskName = "ttyd - Editor Launcher"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

Write-Host "Done. ttyd services will start at next login." -ForegroundColor Green
$pwshCommand = "devenv (```$null | fzf --bind 'change:reload-sync(Start-Sleep -m 100; es -sort date-modified-descending count:100 -p *.sln {q:1} {q:2} {q:3} {q:4} {q:5} {q:6} {q:7} {q:8} {q:9})' --phony --query '' --header='Search - .NET Solutions')"
$action = New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"ttyd -p 4090 -t fontSize=20 -t disableLeaveAlert=true --writable -w . pwsh -c `"`"$pwshCommand`"`" `""
# To debug above action, uncomment and use below line:
# Start-Process -FilePath $action.Execute -ArgumentList $action.Arguments

$taskName = "ttyd - Visual Studio Launcher"
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -Hidden # Remove the -Hidden flag when debugging
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force

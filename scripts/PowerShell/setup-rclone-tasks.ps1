$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -Hidden

# --no-check-certificate as we're using http to our local servers
$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless powershell -Command `"rclone mount --no-check-certificate --vfs-cache-mode full --vfs-cache-max-size 20G --buffer-size 128M --dir-cache-time 1h --poll-interval 30s --vfs-read-chunk-size 32M media-dav: W:`""
$taskName = "RClone - Media"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless powershell -Command `"rclone mount --vfs-cache-mode full --vfs-cache-max-size 20G --buffer-size 32M --dir-cache-time 1h --poll-interval 30s --vfs-read-chunk-size 32M personal-google-drive: R:`""
$taskName = "RClone - Personal Google Drive"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
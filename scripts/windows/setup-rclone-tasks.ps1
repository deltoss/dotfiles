$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -Hidden

if ($env:CHEZMOI_COMPUTERPURPOSE -eq "personal") {
  # --no-check-certificate as we're using http to our local servers
  $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless powershell -Command `"rclone mount --network-mode --no-check-certificate --vfs-cache-mode full --vfs-cache-max-size 20G --buffer-size 128M --dir-cache-time 1h --poll-interval 30s --vfs-read-chunk-size 32M media-dav: W:`""
  $taskName = "RClone - Media - WebDav"
  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

  $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless powershell -Command `"rclone mount --network-mode --vfs-cache-mode full --vfs-cache-max-size 20G --buffer-size 32M --dir-cache-time 1h --poll-interval 30s --vfs-read-chunk-size 32M personal-google-drive: R:`""
  $taskName = "RClone - Mount Personal Drive - Google Drive"
  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

  $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless powershell -Command `"Remove-Item '$env:USERPROFILE\Documents\Personal' -Force -ErrorAction SilentlyContinue; rclone mount --vfs-cache-mode full --vfs-cache-max-size 20G --buffer-size 32M --dir-cache-time 1h --poll-interval 30s --vfs-read-chunk-size 32M personal-google-drive: '$env:USERPROFILE\Documents\Personal'`""
  $taskName = "RClone - Mount Personal Folder - Google Drive"
  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
}

$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless powershell -Command `"rclone mount --network-mode --vfs-cache-mode full --vfs-cache-max-size 20G --buffer-size 32M --dir-cache-time 1h --poll-interval 30s --vfs-read-chunk-size 32M notes-google-drive: N:`""
$taskName = "RClone - Mount Notes Drive - Google Drive"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

$action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless powershell -Command `"Remove-Item '$env:USERPROFILE\Documents\Synced Notes' -Force -ErrorAction SilentlyContinue; rclone mount --vfs-cache-mode full --vfs-cache-max-size 20G --buffer-size 32M --dir-cache-time 1h --poll-interval 30s --vfs-read-chunk-size 32M notes-google-drive: '$env:USERPROFILE\Documents\Synced Notes'`""
$taskName = "RClone - Mount Notes Folder - Google Drive"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
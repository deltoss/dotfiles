$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -Hidden

if ($env:CHEZMOI_COMPUTERPURPOSE -eq "personal")
{
  # --no-check-certificate as we're using http to our local servers
  $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless pwsh -Command `"rclone mount --no-check-certificate --vfs-cache-mode full --vfs-cache-max-size 20G --buffer-size 128M --dir-cache-time 1h --poll-interval 30s --vfs-read-chunk-size 32M media-dav: W:`""
  $taskName = "RClone - Media"
  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

  $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless pwsh -Command `"rclone mount --vfs-cache-mode full --vfs-cache-max-size 20G --buffer-size 32M --dir-cache-time 1h --poll-interval 30s --vfs-read-chunk-size 32M personal-google-drive: R:`""
  $taskName = "RClone - Personal Google Drive"
  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

  rclone config update media-dav pass (op read "op://Personal/Copyparty/password") # Updates the password. Note it's encrypted
  rclone config update personal-google-drive # Updates the access token
  Write-Host "Updating sensitive values" -ForegroundColor Green
}

Write-Host "Done. RClone services will start at next login." -ForegroundColor Green
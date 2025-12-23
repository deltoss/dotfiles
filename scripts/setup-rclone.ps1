$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -Hidden

if ($env:CHEZMOI_COMPUTERPURPOSE -eq "personal")
{
  $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless pwsh -Command `"rclone mount --no-console --no-check-certificate --vfs-cache-mode writes --dir-cache-time 5s media-dav: W:`""
  $taskName = "RClone - Media"
  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

  $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless pwsh -Command `"rclone mount personal-google-drive: R:`""
  $taskName = "RClone - Personal Google Drive"
  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

  rclone config update media-dav pass (op read "op://Personal/Copyparty/password") # Updates the password. Note it's encrypted
  rclone config update personal-google-drive # Updates the access token
  Write-Host "Updating sensitive values" -ForegroundColor Green
}

Write-Host "Done. RClone services will start at next login." -ForegroundColor Green

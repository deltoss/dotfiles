# Create shortcuts for all .ahk files in current directory
$WshShell = New-Object -comObject WScript.Shell
$CurrentPath = Get-Location
$StartupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# Get all .ahk files in current directory
$AhkFiles = Get-ChildItem -Path $CurrentPath -Filter "*.ahk" -File

if ($AhkFiles.Count -eq 0)
{
  Write-Host "No .ahk files found in the current directory: $CurrentPath" -ForegroundColor Yellow
  exit
}

Write-Host "Found $($AhkFiles.Count) .ahk file(s) in: $CurrentPath" -ForegroundColor Green
Write-Host ""

foreach ($AhkFile in $AhkFiles)
{
  # Create shortcut name based on the .ahk filename
  $ShortcutName = [System.IO.Path]::GetFileNameWithoutExtension($AhkFile.Name)
  $ShortcutPath = "$StartupFolder\$ShortcutName.lnk"

  # Create the shortcut
  $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
  $Shortcut.TargetPath = $AhkFile.FullName
  $Shortcut.Save()

  Write-Host "Created shortcut for: $ShortcutName" -ForegroundColor Green
}
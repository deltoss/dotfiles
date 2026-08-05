# Starts Syncthing detached, so it is usable right after install without a
# reboot or re-login.
#
# Why PowerShell and not the install script: nushell has no `&` background
# operator (it passes `&` to the command as an argument), and `job spawn` jobs
# are killed when the shell exits. Start-Process is the only detach that
# outlives the installation script.

if (Get-Process syncthing -ErrorAction SilentlyContinue) {
  Write-Host "Syncthing is already running, leaving it alone." -ForegroundColor Yellow
  return
}

# postcommands run before refresh-path, so a freshly created winget shim may not
# be resolvable on PATH yet. Fall back to the shim directory.
$exe = (Get-Command syncthing -ErrorAction SilentlyContinue).Source
if (-not $exe) {
  $shim = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\syncthing.exe'
  if (Test-Path $shim) { $exe = $shim }
}
if (-not $exe) {
  Write-Host "syncthing not found, skipping start." -ForegroundColor Yellow
  return
}

# --no-browser so it does not pop the GUI, --no-console to hide the window.
Start-Process -FilePath $exe -ArgumentList 'serve', '--no-browser', '--no-console' -WindowStyle Hidden
Write-Host "Syncthing started. GUI at http://127.0.0.1:8384" -ForegroundColor Green
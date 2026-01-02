if (Get-Command wezterm -ErrorAction SilentlyContinue) {
  Write-Host "Already installed" -ForegroundColor Green
  Write-Host "Skipping installation..." -ForegroundColor Green
  return
}

$targetTempPath = "$((Get-Item $env:TEMP).FullName)/PsInstallTools"
if (Test-Path $targetTempPath) {
    Remove-Item -Path $targetTempPath -Recurse -Force
}
git clone https://github.com/deltoss/PsInstallTools.git $targetTempPath
Import-Module -Verbose $targetTempPath
Start-ExeFromUrl "https://github.com/wezterm/wezterm/releases/download/nightly/WezTerm-nightly-setup.exe"
Remove-Module -Verbose PsInstallTools
Remove-Item -Path $targetTempPath -Recurse -Force

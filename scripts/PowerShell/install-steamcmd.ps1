$locations = @(
    "$env:LOCALAPPDATA\Programs\steamcmd"
)

foreach ($path in $locations) {
    if (Test-Path $path) {
        Write-Host "Already installed at: $path" -ForegroundColor Green
        Write-Host "Skipping installation..." -ForegroundColor Green
        return
    }
}

$targetTempPath = "$((Get-Item $env:TEMP).FullName)/PsInstallTools"
if (Test-Path $targetTempPath) {
    Remove-Item -Path $targetTempPath -Recurse -Force
}
git clone https://github.com/deltoss/PsInstallTools.git $targetTempPath
Import-Module -Verbose $targetTempPath
Install-ExeBinaryFromUrl "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" "steamcmd"
Remove-Module -Verbose PsInstallTools
Remove-Item -Path $targetTempPath -Recurse -Force

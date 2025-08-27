$locations = @(
    "$env:ProgramFiles\Mechvibes",
    "${env:ProgramFiles(x86)}\Mechvibes",
    "$env:LOCALAPPDATA\Mechvibes",
    "$env:APPDATA\Mechvibes"
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
Start-ExeFromUrl "https://github.com/hainguyents13/mechvibes/releases/download/v2.3.4/Mechvibes.Setup.2.3.4.exe"
Remove-Module -Verbose PsInstallTools
Remove-Item -Path $targetTempPath -Recurse -Force

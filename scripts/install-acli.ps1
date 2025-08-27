$locations = @(
    "$env:LOCALAPPDATA\Programs\acli"
)

foreach ($path in $locations) {
    if (Test-Path $path) {
        Write-Host "Already found at: $path" -ForegroundColor Green
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

$targetTempFolder = "$((Get-Item $env:TEMP).FullName)/Atlassian CLI"
New-Item -Path $targetTempFolder -ItemType Directory -Force
Invoke-WebRequest -Uri  https://acli.atlassian.com/windows/latest/acli_windows_amd64/acli.exe -OutFile "$targetTempFolder/acli.exe"
Install-FromFolder $targetTempFolder "acli"
Remove-Item -Path $targetTempFolder -Recurse -Force

Remove-Module -Verbose PsInstallTools
Remove-Item -Path $targetTempPath -Recurse -Force

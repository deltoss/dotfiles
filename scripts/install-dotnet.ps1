        irm "https://dot.net/v1/dotnet-install.ps1" | Out-File $tempScript
        & $tempScript -Channel LTS
        & $tempScript -Channel STS
# See:
# - https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script
# - https://github.com/dotnet/install-scripts
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    $tempScript = Join-Path ([System.IO.Path]::GetTempPath()) "dotnet-install.ps1"
    try {
        irm "https://dot.net/v1/dotnet-install.ps1" | Out-File $tempScript
        & $tempScript -Channel LTS
        & $tempScript -Channel STS
    } finally {
        Remove-Item $tempScript -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "dotnet already installed"
}

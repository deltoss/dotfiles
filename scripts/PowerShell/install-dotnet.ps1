# See:
# - https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script
# - https://github.com/dotnet/install-scripts
if (Get-Command dotnet -ErrorAction SilentlyContinue)
{
  Write-Host "dotnet already installed. Checking if SDKs are installed."
  $sdks = dotnet --list-sdks
  if ($sdks)
  {
    Write-Host "dotnet already installed with the following SDKs:"
    Write-Host $sdks
    return
  }
  Write-Host "No sdk was installed. Installing..."
}

$tempScript = Join-Path ([System.IO.Path]::GetTempPath()) "dotnet-install.ps1"
try
{
  irm "https://dot.net/v1/dotnet-install.ps1" | Out-File $tempScript
  & $tempScript -Channel LTS
  & $tempScript -Channel STS
} finally
{
  Remove-Item $tempScript -ErrorAction SilentlyContinue
}
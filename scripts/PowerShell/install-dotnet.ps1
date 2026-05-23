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
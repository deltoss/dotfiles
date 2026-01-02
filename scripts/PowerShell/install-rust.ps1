if (-not (Get-Command rustc -ErrorAction SilentlyContinue))
{
  $url = "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
  $outputPath = "$env:TEMP\rustup-init.exe"

  Write-Host "Downloading rustup-init.exe..." -ForegroundColor Cyan
  Invoke-WebRequest -Uri $url -OutFile $outputPath

  if (Test-Path $outputPath)
  {
    Write-Host "Download complete. Running installer..." -ForegroundColor Green

    Start-Process -FilePath $outputPath -Wait

    Remove-Item $outputPath -Force
    Write-Host "Installation complete and installer cleaned up." -ForegroundColor Green

    # Refresh path for existing terminal session to use Rust
    $env:PATH = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')

    # Swap to use GNU instead of MSVC which relies of Windows tools
    rustup toolchain install stable-x86_64-pc-windows-gnu
    rustup default stable-x86_64-pc-windows-gnu
  } else
  {
    Write-Host "Download failed!" -ForegroundColor Red
  }
} else
{
  Write-Host "Rust already installed"
}
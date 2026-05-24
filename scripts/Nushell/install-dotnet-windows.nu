#!/usr/bin/env nu

let temp_script = (mktemp "dotnet-install.XXXXXXXX.ps1")
try {
  http get "https://dot.net/v1/dotnet-install.ps1" | save --force $temp_script
  powershell -ExecutionPolicy Bypass -File $temp_script --Channel LTS
  powershell -ExecutionPolicy Bypass -File $temp_script --Channel STS
} finally {
  rm -f $temp_script
}
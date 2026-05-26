#!/usr/bin/env nu

let locations = [
  $"($env.ProgramFiles)\\Mechvibes"
  $"($env.'ProgramFiles(x86)')\\Mechvibes"
  $"($env.LOCALAPPDATA)\\Mechvibes"
  $"($env.APPDATA)\\Mechvibes"
]

let installed = $locations | any { path exists }
if ($installed | is-not-empty) {
  print $"(ansi green)Already installed at: ($installed)(ansi reset)"
  print $"(ansi green)Skipping installation...(ansi reset)"
  exit 0
}

let temp_installer = (mktemp --suffix .exe)

try {
  http get "https://github.com/hainguyents13/mechvibes/releases/download/v2.3.4/Mechvibes.Setup.2.3.4.exe" | save --force $temp_installer
  ^$temp_installer
  print $"(ansi green)Press Enter once the installation is complete...(ansi reset)"
  input
} finally {
  rm -f $temp_installer
}
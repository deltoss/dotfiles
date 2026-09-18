#!/usr/bin/env nu

use ./helpers/refresh-path.nu

let url = "https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Windows_64bit.msi"
let temp_msi = ($nu.temp-dir | path join "arduino-cli-installer.msi")

print $"(ansi cyan)Downloading Arduino CLI installer...(ansi reset)"
http get $url | save --force $temp_msi

try {
  print $"(ansi cyan)Running installer...(ansi reset)"
  let result = (^msiexec /i $temp_msi /qn /norestart | complete)
  if $result.exit_code == 0 {
    print $"(ansi green)Installation complete.(ansi reset)"
    refresh-path
  } else if $result.exit_code == 1603 {
    print $"(ansi red)Install failed \(exit 1603\): this needs to run elevated. Run via `chezmoi apply` \(which self-elevates\), or from an admin shell.(ansi reset)"
  } else {
    print $"(ansi red)Install failed, msiexec exit code ($result.exit_code)(ansi reset)"
  }
} finally {
  rm -f $temp_msi
}

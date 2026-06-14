#!/usr/bin/env nu

print $"(ansi green)Configuring rclone...(ansi reset)"

let configs = rclone config redacted | split row "\n\n"

let is_config_setup = $configs | any { $in =~ notes-google-drive and $in =~ "token = .+" }
if (not $is_config_setup) {
  print $"(ansi green)Updating sensitive values...(ansi reset)"
  rclone config update notes-google-drive # Updates the access token
}

if ($env.CHEZMOI_COMPUTERPURPOSE == "personal") {
  let is_config_setup = $configs | any { $in =~ media-dav and $in =~ "pass = .+" }
  if (not $is_config_setup) {
    print $"(ansi green)Updating sensitive values specifically for personal computer...(ansi reset)"
    rclone config update media-dav pass (^chezmoi data --format json | from json | get copyparty_password) # Updates the password. Note it's encrypted
  }

  let is_config_setup = $configs | any { $in =~ personal-google-drive and $in =~ "token = .+" }
  if (not $is_config_setup) {
    print $"(ansi green)Updating sensitive values specifically for personal-google-drive...(ansi reset)"
    rclone config update personal-google-drive # Updates the access token
  }
}

if (sys host).name =~ "Windows" {
  print $"(ansi green)Configuring startup for Windows...(ansi reset)"
  ^powershell -ExecutionPolicy Bypass -File $'($env.CHEZMOI_SOURCEDIR)/scripts/windows/setup-rclone-tasks.ps1'
}
print $"(ansi green)Done. rclone services will start at next login.(ansi reset)"
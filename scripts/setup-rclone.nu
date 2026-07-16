#!/usr/bin/env nu

const HERE = (path self | path dirname)

print $"(ansi green)Configuring rclone...(ansi reset)"

let configs = rclone config redacted | split row "\n\n"

let is_config_setup = $configs | any { $in =~ personal-google-drive and $in =~ "token = .+" }
if (not $is_config_setup) {
  print $"(ansi green)Updating sensitive values specifically for personal-google-drive...(ansi reset)"
  rclone config update personal-google-drive # Updates the access token
}

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
}

if (sys host).name =~ "Windows" {
  print $"(ansi green)Configuring startup for Windows...(ansi reset)"
  ^powershell -ExecutionPolicy Bypass -File $'($HERE)/windows/setup-rclone-tasks.ps1'
} else if (sys host).name =~ "Linux" {
  print $"(ansi green)Configuring startup for Linux...(ansi reset)"
  nu $'($HERE)/linux/setup-rclone-mounts.nu'
}
print $"(ansi green)Done. rclone services will start at next login.(ansi reset)"
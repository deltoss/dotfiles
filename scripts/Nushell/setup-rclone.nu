#!/usr/bin/env nu

print $"(ansi green)Configuring rclone...(ansi reset)"

let is_config_setup = rclone config redacted | lines | any { $in =~ notes-google-drive }
if (not $is_config_setup) {
  print $"(ansi green)Updating sensitive values...(ansi reset)"
  rclone config update notes-google-drive # Updates the access token
}

if ($env.CHEZMOI_COMPUTERPURPOSE == "personal") {
  let is_config_setup = rclone config redacted | lines | any { $in =~ media-dav }
  if (not $is_config_setup) {
    print $"(ansi green)Updating sensitive values specifically for personal computer...(ansi reset)"
    rclone config update media-dav pass (op read "op://Personal/Copyparty/password") # Updates the password. Note it's encrypted
    rclone config update personal-google-drive # Updates the access token
  }
}

if (sys host).name =~ "Windows" {
  print $"(ansi green)Configuring startup for Windows...(ansi reset)"
  ^powershell -ExecutionPolicy Bypass -File $'($env.CHEZMOI_SOURCEDIR)/scripts/PowerShell/setup-rclone-tasks.ps1'
}
print $"(ansi green)Done. rclone services will start at next login.(ansi reset)"
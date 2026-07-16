#!/usr/bin/env nu

# Enables the rclone mount systemd --user units that chezmoi has already
# deployed to ~/.config/systemd/user/ (see dot_config/systemd/user/rclone-*).
# This is the Linux equivalent of scripts/windows/setup-rclone-tasks.ps1's
# scheduled tasks: units are set to start at login (WantedBy=default.target)
# and restart on failure.

print $"(ansi green)Configuring rclone mount services for Linux...(ansi reset)"

systemctl --user daemon-reload

let units = [
  "rclone-personal-google-drive.service"
  "rclone-notes-google-drive.service"
]

for $unit in $units {
  print $"(ansi blue)Enabling ($unit)...(ansi reset)"
  systemctl --user enable --now $unit
}

print $"(ansi green)Done. rclone mounts will start at next login.(ansi reset)"
print "If you want them mounted before login too \(e.g. on a headless boot\), run:"
print $"  loginctl enable-linger ($env.USER)"

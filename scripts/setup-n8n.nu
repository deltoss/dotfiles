#!/usr/bin/env nu

const HERE = path self | path dirname

if (sys host).name =~ "Windows" {
  use windows/helpers/refresh-path.nu
  refresh-path
  ^powershell -NoProfile -ExecutionPolicy Bypass -File ($HERE | path join "windows" "setup-n8n-task.ps1")
} else if (sys host).name =~ "Linux" {
  if (which n8n | is-empty) {
    print "n8n is not installed, skipping."
    return
  }
  systemctl --user daemon-reload
  systemctl --user enable --now n8n.service
}

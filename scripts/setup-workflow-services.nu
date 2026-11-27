#!/usr/bin/env nu

const HERE = path self | path dirname

if (sys host).name =~ "Windows" {
  use windows/helpers/refresh-path.nu
  refresh-path
  ^powershell -NoProfile -ExecutionPolicy Bypass -File ($HERE | path join "windows" "setup-workflow-tasks.ps1")
} else if (sys host).name =~ "Linux" {
  systemctl --user daemon-reload
  for tool in [dagu n8n] {
    if (which $tool | is-not-empty) {
      systemctl --user enable --now $"($tool).service"
    }
  }
}

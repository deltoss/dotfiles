#!/usr/bin/env nu

match (sys host).name {
  "Windows" => {
    print "Setting up ttyd scheduled tasks..."
    ^powershell -ExecutionPolicy Bypass -File $"($env.CHEZMOI_SOURCEDIR)/scripts/PowerShell/setup-ttyd-tasks.ps1"
  }
}
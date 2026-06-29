#!/usr/bin/env nu

const HERE = (path self | path dirname)

match (sys host).name {
  "Windows" => {
    print "Setting up ttyd scheduled tasks..."
    ^powershell -ExecutionPolicy Bypass -File $"($HERE)/windows/setup-ttyd-tasks.ps1"
  }
}
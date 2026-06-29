#!/usr/bin/env nu

const HERE = (path self | path dirname)

print $"(ansi green)Configuring podman...(ansi reset)"

podman machine init
podman machine start

if (sys host).name =~ "Windows" {
  print $"(ansi green)Configuring startup for Windows...(ansi reset)"
  ^powershell -ExecutionPolicy Bypass -File $'($HERE)/windows/setup-podman-tasks.ps1'
  print $"(ansi green)Done. podman services will start at next login.(ansi reset)"
}
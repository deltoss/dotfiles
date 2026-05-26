#!/usr/bin/env nu

print $"(ansi green)Configuring podman...(ansi reset)"

podman machine init
podman machine start

if (sys host).name =~ "Windows" {
  print $"(ansi green)Configuring startup for Windows...(ansi reset)"
  ^powershell -ExecutionPolicy Bypass -File $'($env.CHEZMOI_SOURCEDIR)/scripts/windows/setup-podman-tasks.ps1'
  print $"(ansi green)Done. podman services will start at next login.(ansi reset)"
}
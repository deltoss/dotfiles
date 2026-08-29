#!/usr/bin/env nu

print $"(ansi green)Installing RTK...(ansi reset)"
if (which rtk | is-not-empty) {
  print "rtk is already installed, skipping."
  return
}

cargo install --git https://github.com/rtk-ai/rtk
$env.PATH = ($env.PATH | prepend ($nu.home-dir | path join ".cargo" "bin"))

print $"(ansi green)Configuring RTK...(ansi reset)"

rtk init --global --auto-patch
rtk init --global --codex
rtk init --global --opencode
rtk init --agent pi --global

# OMP uses the Pi extension layout under ~/.omp/agent.
with-env { PI_CODING_AGENT_DIR: ($nu.home-dir | path join ".omp" "agent") } {
  rtk init --agent pi --global
}
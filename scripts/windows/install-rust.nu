#!/usr/bin/env nu

use ./helpers/refresh-path.nu

let url = "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
let output_path = $"($env.TEMP)\\rustup-init.exe"

print $"(ansi cyan)Downloading rustup-init.exe...(ansi reset)"
http get $url | save --force $output_path

if ($output_path | path exists) {
  print $"(ansi green)Download complete. Running installer...(ansi reset)"
  ^$output_path
  rm --force $output_path
  print $"(ansi green)Installation complete and installer cleaned up.(ansi reset)"

  # Refresh PATH for current session
  refresh-path

  # Swap to GNU toolchain instead of MSVC
  rustup toolchain install stable-x86_64-pc-windows-gnu
  rustup default stable-x86_64-pc-windows-gnu

  source ./setup-cargo-environment.nu
} else {
  print $"(ansi red)Download failed!(ansi reset)"
}
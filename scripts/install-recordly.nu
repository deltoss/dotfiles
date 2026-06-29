#!/usr/bin/env nu

const HERE = (path self | path dirname)

# Install Recordly. Dispatches to the platform-specific script:
#   windows -> scripts/windows/install-recordly.nu (NSIS installer)
#   linux   -> scripts/linux/install-recordly.nu   (AppImage)
def main [
  --interactive   # windows only: show the installer UI instead of installing silently
] {
  match $nu.os-info.name {
    "windows" => {
      if $interactive {
        nu $"($HERE)/windows/install-recordly.nu" --interactive
      } else {
        nu $"($HERE)/windows/install-recordly.nu"
      }
    }
    "linux"   => { nu $"($HERE)/linux/install-recordly.nu" }
    $other    => { error make { msg: $"Unsupported OS: ($other)" } }
  }
}

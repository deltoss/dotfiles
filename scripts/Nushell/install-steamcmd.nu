#!/usr/bin/env nu

if (which steamcmd | is-not-empty) {
  let path = (which steamcmd | get path.0)
  print $"(ansi green)Already installed at: ($path)(ansi reset)"
  print $"(ansi green)Skipping installation...(ansi reset)"
  exit 0
}

match (sys host).name {
  "Windows" => {
    nu $"($env.CHEZMOI_SOURCEDIR)/scripts/Nushell/install-steamcmd-windows.nu"
  },
  $x if ($x =~ Debian) => {
    sudo apt update
    # Only necessary for Debian 12/Bookworm. Debian 13/Trixie won't need this
    # sudo apt install software-properties-common
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install steamcmd
  }
}
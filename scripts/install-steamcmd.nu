#!/usr/bin/env nu

if (which steamcmd | is-not-empty) {
  let path = (which steamcmd | get path.0)
  print $"(ansi green)Already installed at: ($path)(ansi reset)"
  print $"(ansi green)Skipping installation...(ansi reset)"
  exit 0
}

match (sys host).name {
  "Windows" => {
    nu $"($env.CHEZMOI_SOURCEDIR)/scripts/windows/install-steamcmd.nu"
  },
  $x if ($x =~ Debian) => {
    nu $"($env.CHEZMOI_SOURCEDIR)/scripts/linux/install-steamcmd-debian.nu"
  }
}
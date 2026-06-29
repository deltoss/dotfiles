#!/usr/bin/env nu

const HERE = (path self | path dirname)

if (which steamcmd | is-not-empty) {
  let path = (which steamcmd | get path.0)
  print $"(ansi green)Already installed at: ($path)(ansi reset)"
  print $"(ansi green)Skipping installation...(ansi reset)"
  exit 0
}

match (sys host).name {
  "Windows" => {
    nu $"($HERE)/windows/install-steamcmd.nu"
  },
  $x if ($x =~ Debian) => {
    nu $"($HERE)/linux/install-steamcmd-debian.nu"
  }
}
#!/usr/bin/env nu

use ./helpers/add-path-env.nu

let install_dir = $"($env.LOCALAPPDATA)\\Programs\\steamcmd"
let temp_zip = (mktemp --suffix .zip)

if ($install_dir | path exists) {
  rm -rf $install_dir
}

try {
  http get "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" | save --force $temp_zip
  mkdir $install_dir
  7z x $temp_zip $"-o($install_dir)" -y

  add-path-env $install_dir
} finally {
  rm -f $temp_zip
}
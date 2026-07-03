#!/usr/bin/env nu

# Installs Handy (speech-to-text, cjpais/Handy) as an AppImage, no Arch package.
# Pulls the latest AppImage from GitHub releases into ~/.local/bin and writes a
# .desktop launcher.
#
# Handy is a Tauri app; on Linux it requires gtk-layer-shell (startup fails
# without it) plus a text-injection tool (xdotool on X11, wtype on Wayland).
# AppImages need FUSE (fuse2). If it misbehaves, these env vars help:
#   WEBKIT_DISABLE_DMABUF_RENDERER=1   HANDY_NO_GTK_LAYER_SHELL=1

const REPO = "cjpais/Handy"

def main [] {
  print "Installing Handy dependencies..."
  sudo pacman -S --needed --noconfirm gtk-layer-shell xdotool wtype fuse2

  let release = (http get $"https://api.github.com/repos/($REPO)/releases/latest")
  let appimages = ($release.assets | where name =~ '(?i)\.appimage$')
  if ($appimages | is-empty) {
    error make { msg: $"No AppImage asset in the latest ($REPO) release" }
  }
  let amd = ($appimages | where name =~ '(?i)amd64|x86_64')
  let asset = (if ($amd | is-not-empty) { $amd | first } else { $appimages | first })

  let bin_dir = ($nu.home-dir | path join ".local" "bin")
  let dest = ($bin_dir | path join "Handy.AppImage")
  mkdir $bin_dir

  print $"Downloading ($asset.name)..."
  http get $asset.browser_download_url | save -f $dest
  chmod +x $dest

  let apps_dir = ($nu.home-dir | path join ".local" "share" "applications")
  mkdir $apps_dir
  $"[Desktop Entry]
Name=Handy
Comment=Speech-to-text
Exec=($dest)
Icon=handy
Type=Application
Categories=Utility;AudioVideo;
Terminal=false
" | save -f ($apps_dir | path join "handy.desktop")

  print $"Handy installed to ($dest). Grant microphone access on first launch."
}

main

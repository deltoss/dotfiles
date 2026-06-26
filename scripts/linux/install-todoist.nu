#!/usr/bin/env nu

# Installs Todoist as an AppImage (no official Arch package). Downloads the
# latest build, drops it in ~/.local/bin, and writes a .desktop launcher so it
# shows in the app menu. AppImages need FUSE to run, so ensure fuse2 is present.

def main [] {
  # AppImages (type 2) need libfuse.so.2; fusermount comes with the fuse2 package.
  if (which fusermount | is-empty) {
    print "Installing fuse2 (required to run AppImages)..."
    sudo pacman -S --needed --noconfirm fuse2
  }

  let bin_dir = ($nu.home-dir | path join ".local" "bin")
  let dest = ($bin_dir | path join "Todoist.AppImage")
  mkdir $bin_dir

  print "Downloading Todoist AppImage..."
  http get "https://todoist.com/linux_app/appimage" | save -f $dest
  chmod +x $dest

  let apps_dir = ($nu.home-dir | path join ".local" "share" "applications")
  mkdir $apps_dir
  $"[Desktop Entry]
Name=Todoist
Exec=($dest)
Icon=todoist
Type=Application
Categories=Office;
Terminal=false
" | save -f ($apps_dir | path join "todoist.desktop")

  print $"Todoist installed to ($dest)"
}

main

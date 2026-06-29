#!/usr/bin/env nu

# Install Recordly on Linux: download the latest AppImage from GitHub and drop
# it into ~/.local/bin, marked executable.

const REPO = "webadderallorg/Recordly"
const ASSET = "Recordly-linux-x64.AppImage"

def main [] {
  let dest = ($nu.home-dir | path join ".local" "bin" "Recordly.AppImage")
  if ($dest | path exists) {
    print $"(ansi green)Recordly already installed at ($dest); skipping...(ansi reset)"
    return
  }

  let release = (http get $"https://api.github.com/repos/($REPO)/releases/latest")
  let asset = ($release.assets | where name == $ASSET | first)
  print $"Downloading Recordly ($release.tag_name)..."

  mkdir ($dest | path dirname)
  http get $asset.browser_download_url | save -f $dest
  ^chmod +x $dest

  print $"Installed to ($dest)"
  print "Make sure ~/.local/bin is on your PATH, then run: Recordly.AppImage"
}

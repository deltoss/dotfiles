#!/usr/bin/env nu

# Install Recordly on Windows: download the latest NSIS installer from GitHub
# and run it (silent by default, /S).

const REPO = "webadderallorg/Recordly"
const ASSET = "Recordly-windows-x64.exe"

# Candidate install dirs; if any exists, Recordly is already installed.
def installed []: nothing -> bool {
  [
    $"($env.ProgramFiles)\\Recordly"
    $"($env.'ProgramFiles(x86)')\\Recordly"
    $"($env.LOCALAPPDATA)\\Programs\\Recordly"
    $"($env.LOCALAPPDATA)\\Recordly"
    $"($env.APPDATA)\\Recordly"
  ] | any { path exists }
}

def main [
  --interactive   # show the installer UI instead of installing silently
] {
  if (installed) {
    print $"(ansi green)Recordly already installed; skipping...(ansi reset)"
    return
  }

  let release = (http get $"https://api.github.com/repos/($REPO)/releases/latest")
  let asset = ($release.assets | where name == $ASSET | first)
  print $"Downloading Recordly ($release.tag_name)..."

  let tmp = (mktemp -d)
  let exe = ($tmp | path join $ASSET)
  http get $asset.browser_download_url | save -f $exe

  if $interactive {
    print "Launching installer..."
    ^$exe
  } else {
    print "Running NSIS installer silently (/S)..."
    ^$exe /S
  }
  print "Installed. Recordly should appear in your Start menu."

  rm -rf $tmp
}

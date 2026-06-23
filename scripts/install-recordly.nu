#!/usr/bin/env nu

# Install Recordly for the current platform.
# Downloads the latest prebuilt asset from GitHub, then runs the
# platform-appropriate install step:
#   windows -> run the NSIS installer (silent by default)
#   linux   -> drop the AppImage into ~/.local/bin and mark it executable

const REPO = "webadderallorg/Recordly"

# Map (os, arch) -> release asset name. Only the combos that ship a build.
def asset-name []: nothing -> string {
    let os = $nu.os-info.name     # "windows" | "linux"
    let arch = $nu.os-info.arch   # "x86_64"

    match [$os $arch] {
        ["windows" "x86_64"]  => "Recordly-windows-x64.exe"
        ["linux"   "x86_64"]  => "Recordly-linux-x64.AppImage"
        _ => { error make { msg: $"No prebuilt Recordly binary for ($os) ($arch)" } }
    }
}

# Download the matching asset into $dir, returning the saved file path.
def download-asset [dir: path]: nothing -> path {
    let want = (asset-name)
    print $"Looking for asset: ($want)"

    let release = (http get $"https://api.github.com/repos/($REPO)/releases/latest")
    print $"Latest release: ($release.tag_name)"

    let matches = ($release.assets | where name == $want)
    if ($matches | is-empty) {
        error make { msg: $"Asset ($want) not found in release ($release.tag_name)" }
    }
    let asset = ($matches | first)

    let out = ($dir | path join $want)
    print $"Downloading ($asset.size | into filesize) -> ($out)"
    http get $asset.browser_download_url | save -f $out
    $out
}

def install-windows [installer: path, silent: bool] {
    if $silent {
        print "Running NSIS installer silently (/S)..."
        ^$installer /S
    } else {
        print "Launching installer..."
        ^$installer
    }
    print "Installed. Recordly should appear in your Start menu."
}

def install-linux [appimage: path] {
    let bindir = ($nu.home-dir | path join ".local" "bin")
    mkdir $bindir
    let dest = ($bindir | path join "Recordly.AppImage")
    cp $appimage $dest
    ^chmod +x $dest
    print $"Installed to ($dest)"
    print "Make sure ~/.local/bin is on your PATH, then run: Recordly.AppImage"
}

# Download and install Recordly for the current platform.
def main [
    --interactive   # windows only: show the installer UI instead of installing silently
] {
    let tmp = (mktemp -d)
    let file = (download-asset $tmp)

    match $nu.os-info.name {
        "windows" => { install-windows $file (not $interactive) }
        "linux"   => { install-linux $file }
        $other    => { error make { msg: $"Unsupported OS: ($other)" } }
    }

    rm -rf $tmp
    print "Done."
}

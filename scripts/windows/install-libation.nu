#!/usr/bin/env nu

let locations = [
  $"($env.ProgramFiles)\\Libation"
  $"($env.'ProgramFiles(x86)')\\Libation"
  $"($env.LOCALAPPDATA)\\Libation"
  $"($env.APPDATA)\\Libation"
]

let installed = $locations | any { path exists }
if ($installed | is-not-empty) {
  print $"(ansi green)Already installed at: ($installed)(ansi reset)"
  print $"(ansi green)Skipping installation...(ansi reset)"
  exit 0
}

let release = (http get https://api.github.com/repos/rmcrackan/libation/releases/latest)
let asset = ($release.assets | where name =~ "windows-chardonnay-x64-setup.exe" | first)
let url = $asset.browser_download_url
let filename = $asset.name
let tmpdir = (mktemp -d)
let exepath = $"($tmpdir)/($filename)"

print $"Downloading Libation ($release.tag_name)..."
http get $url | save $exepath

run-external $exepath

print "Cleaning up..."
rm -rf $tmpdir
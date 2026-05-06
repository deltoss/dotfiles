#!/usr/bin/env nu

def sunshine-installed [] {
    ("C:\\Program Files\\Sunshine\\sunshine.exe" | path exists)
}

let url = "https://github.com/LizardByte/Sunshine/releases/latest/download/Sunshine-Windows-AMD64-installer.exe"
let installer = ($nu.temp-dir | path join "Sunshine-installer.exe")

if (sunshine-installed) {
    print "Sunshine is already installed, skipping."
} else {
    print $"Downloading Sunshine to ($installer)..."
    http get $url | save -f $installer

    print "Running installer..."
    ^$installer

    print "Done!"
}
#!/usr/bin/env nu

let url = "https://github.com/LizardByte/Sunshine/releases/latest/download/Sunshine-Windows-AMD64-installer.exe"
let temp_exe_path = ($nu.temp-dir | path join "Sunshine-installer.exe")

if (which sunshine | is-not-empty) {
    print "Sunshine is already installed, skipping."
} else {
    print $"Downloading Sunshine to ($temp_exe_path)..."
    http get $url | save -f $temp_exe_path

    print "Running installer..."
    ^$temp_exe_path

    print "Done!"
}
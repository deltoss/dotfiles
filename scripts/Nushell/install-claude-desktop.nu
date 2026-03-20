#!/usr/bin/env nu

def is_installed [] {
    # Claude Desktop installs as an MSIX package — query via Get-AppxPackage
    let result = (^powershell -NoProfile -Command "Get-AppxPackage -Name '*Claude*' | Select-Object -ExpandProperty Name" | str trim)
    $result | is-not-empty
}

def main [] {
    if (is_installed) {
        print $"(ansi yellow)✓ Claude Desktop is already installed — nothing to do.(ansi reset)"
        return
    }

    let url = "https://downloads.claude.ai/releases/win32/ClaudeSetup.exe"
    let installer = $"($env.TEMP)\\ClaudeSetup.exe"

    print $"(ansi cyan)→ Downloading Claude Desktop for Windows x64…(ansi reset)"
    http get $url | save --force $installer

    print $"(ansi cyan)→ Running installer… a UAC prompt may appear.(ansi reset)"
    # /S for silent install; remove if you want the GUI wizard
    run-external $installer "/S"

    print $"(ansi green)✓ Claude Desktop installed! Launch it from the Start menu.(ansi reset)"
}

main

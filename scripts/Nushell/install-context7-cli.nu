#!/usr/bin/env nu

def is_installed [] {
    let result = npx ctx7 whoami | complete
    $result.stdout =~ 'Logged in'
}

def main [] {
    if (is_installed) {
        print $"(ansi yellow)✓ Context7 CLI is already installed — nothing to do.(ansi reset)"
        return
    }

    print $"(ansi cyan)→ Setting up ctx7…(ansi reset)"
    npx ctx7 setup --cli

    # Make sure you select CLI, not the MCP!
    npx ctx7 setup --opencode
    npx ctx7 setup --claude

    print $"(ansi green)✓ Context7 installed!(ansi reset)"
}

main
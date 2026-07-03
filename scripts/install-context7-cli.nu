#!/usr/bin/env nu

def is_installed [] {
  let result = npx ctx7 whoami | complete
  $result.stdout =~ 'Logged in'
}

# ctx7 setup performs an interactive OAuth device login; only run it with a TTY.
def is_interactive [] {
  (do -i { ^test -t 0 } | complete | get exit_code) == 0
}

def main [] {
  if (is_installed) {
    print $"(ansi yellow)✓ Context7 CLI is already installed, nothing to do.(ansi reset)"
    return
  }

  if not (is_interactive) {
    print $"(ansi yellow)⚠ Context7 needs interactive OAuth login; skipping in unattended run.(ansi reset)"
    print $"(ansi yellow)  Run manually: npx ctx7 setup --cli; npx ctx7 setup --opencode; npx ctx7 setup --claude(ansi reset)"
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
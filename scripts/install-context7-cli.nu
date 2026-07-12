#!/usr/bin/env nu

def is_installed [] {
  (which ctx7 | length) > 0
}

def main [] {
  if (is_installed) {
    print $"(ansi yellow)✓ Context7 CLI is already installed, nothing to do.(ansi reset)"
    return
  }

  # ctx7 setup performs an interactive OAuth device login; only run it with a TTY.
  let is_interactive = is-terminal --stdin
  if not ($is_interactive) {
    print $"(ansi yellow)⚠ Context7 needs interactive OAuth login; skipping in unattended run.(ansi reset)"
    print $"(ansi yellow)  Run manually: npm install -g ctx7 && ctx7 setup --cli && ctx7 setup --opencode && ctx7 setup --claude(ansi reset)"
    return
  }

  print $"(ansi cyan)→ Installing ctx7 globally…(ansi reset)"
  npm install -g ctx7

  print $"(ansi cyan)→ Setting up ctx7…(ansi reset)"
  ctx7 setup --cli

  # Make sure you select CLI, not the MCP!
  ctx7 setup --opencode
  ctx7 setup --claude

  print $"(ansi green)✓ Context7 installed!(ansi reset)"
}

main

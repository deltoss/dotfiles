if (which serena | is-not-empty) {
  print "Serena is already installed, skipping."
} else {
  print $"Running installer..."
  uv tool install -p 3.13 serena-agent@latest --prerelease=allow

  print "Configuring Serena..."
  serena init
  # Only configure clients that are actually installed. codex comes from the
  # cross-platform package list, which installs after the Linux packages, so it
  # is typically absent when Serena runs here.
  if (which claude | is-not-empty) { serena setup claude-code }
  if (which codex | is-not-empty) { serena setup codex }

  print "Done!"
}
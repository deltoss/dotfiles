if (which serena | is-not-empty) {
  print "Serena is already installed, skipping."
} else {
  print $"Running installer..."
  uv tool install -p 3.13 serena-agent@latest --prerelease=allow

  print "Configuring Serena..."
  serena init
  serena setup claude-code
  serena setup codex

  print "Done!"
}
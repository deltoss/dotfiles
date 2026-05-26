# Check if wezterm is already installed
if (which wezterm | is-not-empty) {
  print $"(ansi green)Already installed(ansi reset)"
  print $"(ansi green)Skipping installation...(ansi reset)"
  return
}

match (sys host).name {
  "Windows" => {
    nu $"($env.CHEZMOI_SOURCEDIR)/scripts/windows/install-wezterm-nightly.nu"
  },
  $x if ($x =~ Debian) => {
    sudo apt install wezterm-nightly
  }
}
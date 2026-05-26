if (which rustc | is-not-empty) {
  print "Rust already installed"
  exit 0
}

match (sys host).name {
  "Windows" => {
    nu $"($env.CHEZMOI_SOURCEDIR)/scripts/windows/install-rust.nu"
  }
}
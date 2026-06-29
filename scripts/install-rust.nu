const HERE = (path self | path dirname)

if (which rustc | is-not-empty) {
  print "Rust already installed"
  exit 0
}

match (sys host).name {
  "Windows" => {
    nu $"($HERE)/windows/install-rust.nu"
  }
}
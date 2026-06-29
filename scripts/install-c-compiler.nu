const HERE = (path self | path dirname)

if (which clang | is-not-empty) {
  print "clang already installed"
  exit 0
}

match (sys host).name {
  "Windows" => {
    nu $"($HERE)/windows/install-msys2-clang-with-headers.nu"
  },
  $x if ($x =~ Debian) => {
    sudo apt install clang llvm
  }
  $x if ($x =~ Ubuntu) => {
    sudo apt install clang llvm
  }
}
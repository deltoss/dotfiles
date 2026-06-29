#!/usr/bin/env nu

const HERE = (path self | path dirname)

# See:
# - https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script
# - https://github.com/dotnet/install-scripts
if (which dotnet | is-not-empty) {
  print "dotnet already installed. Checking if SDKs are installed."
  let sdks = (^dotnet --list-sdks)
  if ($sdks | is-not-empty) {
    print "dotnet already installed with the following SDKs:"
    print $sdks
    exit 0
  }
  print "No sdk was installed. Installing..."
}

match (sys host).name {
  "Windows" => {
    print "Downloading and installing dotnet LTS + STS for Windows..."
    nu $"($HERE)/windows/install-dotnet.nu"
  }
  _ => {
    print "On Linux, dotnet is installed via the system package manager (pacman: dotnet-sdk), not this script."
  }
}
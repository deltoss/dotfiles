#!/usr/bin/env nu

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
    nu $"($env.CHEZMOI_SOURCEDIR)/scripts/Nushell/install-dotnet-windows.nu"
  }
  _ => {
    print "Downloading and installing dotnet LTS + STS for Linux..."
    nu $"($env.CHEZMOI_SOURCEDIR)/scripts/Nushell/install-dotnet-linux.sh"
  }
}
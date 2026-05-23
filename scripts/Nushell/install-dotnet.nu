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
    ^powershell -ExecutionPolicy Bypass -File $"($env.CHEZMOI_SOURCEDIR)/scripts/PowerShell/install-dotnet.ps1"
  }
  _ => {
    print "Downloading and installing dotnet LTS + STS for Linux..."
    ^bash $"($env.CHEZMOI_SOURCEDIR)/scripts/Bash/install-dotnet.sh"
  }
}
#!/usr/bin/env nu

let temp_script = (mktemp /tmp/dotnet-install.XXXXXXXX)
try {
  http get "https://dot.net/v1/dotnet-install.sh" | save --force $temp_script
  chmod +x $temp_script
  bash $temp_script --channel LTS
  bash $temp_script --channel STS
} finally {
  rm -f $temp_script
}
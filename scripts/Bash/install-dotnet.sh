#!/usr/bin/env bash
set -euo pipefail

tempScript=$(mktemp /tmp/dotnet-install.XXXXXXXX)
trap 'rm -f "$tempScript"' EXIT

curl -sSL "https://dot.net/v1/dotnet-install.sh" -o "$tempScript"
chmod +x "$tempScript"
"$tempScript" --channel LTS
"$tempScript" --channel STS

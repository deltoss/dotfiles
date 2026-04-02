# Usage:
#   source refresh-path.nu
$env.Path = (
  [
    (registry query --hkcu "Environment" "Path" | get value | split row ";"),
    (registry query --hklm "SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment" "Path" | get value | split row ";")
  ]
  | flatten
)
# Rebuilds $env.Path from the Windows registry (machine + user) so a tool an
# installer just added to PATH is visible immediately in the current session.
#
# Usage:
#   use refresh-path.nu
#   refresh-path
export def --env main [] {
  $env.Path = (
    [
      (registry query --hklm "SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment" "Path" | get value | split row ";"),
      (registry query --hkcu "Environment" "Path" | get value | split row ";")
    ]
    | flatten
  )
}

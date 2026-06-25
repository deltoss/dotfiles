# Rebuilds $env.Path from the Windows registry (machine + user) so a tool an
# installer just added to PATH is visible immediately in the current session.
#
# Usage:
#   use refresh-path.nu
#   refresh-path
export def --env main [] {
  let sys_path = registry query --hklm 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment' Path
    | get value | split row ';' | compact --empty
  let user_path = registry query --hkcu Environment Path
    | get value | split row ';' | compact --empty

  # System first, then user (Windows precedence), then any session-local
  # additions; dedup case-insensitively.
  $env.Path = $sys_path ++ $user_path ++ $env.Path | uniq --ignore-case
}
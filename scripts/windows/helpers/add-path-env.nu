# Append a directory to the User PATH environment variable on Windows if not
# already present. Refreshes the current session's $env.Path so the change
# takes effect immediately.
#
# Usage:
#   use windows/helpers/add-path-env.nu
#   add-path-env $cargo_dir
use ./refresh-path.nu

export def --env main [dir: string] {
  if ($dir in $env.Path) {
    return
  }

  let user_paths = ^powershell -Command "[Environment]::GetEnvironmentVariable('PATH', 'User')" | str trim --right --char ";"
  let user_paths = $'($user_paths);($dir)'
  ^powershell -Command $"[Environment]::SetEnvironmentVariable\('PATH', '($user_paths)', 'User'\)"
  refresh-path # Refresh paths so it'd work immediately
}
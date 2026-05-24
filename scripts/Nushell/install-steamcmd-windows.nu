let install_dir = $"($env.LOCALAPPDATA)\\Programs\\steamcmd"
let temp_zip = (mktemp --suffix .zip)

if ($install_dir | path exists) {
  rm -rf $install_dir
}

try {
  http get "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" | save --force $temp_zip
  mkdir $install_dir
  7z x $temp_zip $"-o($install_dir)" -y

  if not ($install_dir in $env.Path) {
    let user_paths = ^powershell -Command "[Environment]::GetEnvironmentVariable('PATH', 'User')"
    let user_paths = $'($user_paths | str trim --right --char ";");($install_dir);'
    ^powershell -Command $"[Environment]::SetEnvironmentVariable\('PATH', '($user_paths)', 'User'\)"
    source ./refresh-path.nu # Refresh paths so it'd work immediately
  }
} finally {
  rm -f $temp_zip
}
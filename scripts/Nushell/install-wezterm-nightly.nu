# Check if wezterm is already installed
if (which wezterm | is-not-empty) {
  print $"(ansi green)Already installed(ansi reset)"
  print $"(ansi green)Skipping installation...(ansi reset)"
  return
}

let target_temp_path = $"($env.TEMP)/WeztermNightly"
if ($target_temp_path | path exists) {
  rm -rf $target_temp_path
}
mkdir $target_temp_path

let installer_path = $"($target_temp_path)/WezTerm-nightly-setup.exe"
http get "https://github.com/wezterm/wezterm/releases/download/nightly/WezTerm-nightly-setup.exe"
  | save -f $installer_path

^$installer_path

rm -rf $target_temp_path
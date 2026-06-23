def main --env [path: string] {
  let adjusted_path = $path | str replace --all '\' '/'
  if ("ZELLIJ" in $env) {
    zellij run --stacked --close-on-exit -- $env.EDITOR $adjusted_path
  } else {
    ^$env.EDITOR $adjusted_path
  }
}

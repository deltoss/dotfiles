def main --env [path: string] {
  let adjusted_path = $path | str replace --all '\' '/'
  if ("ZELLIJ" in $env) {
    zellij run --stacked --close-on-exit --name "" -- $env.EDITOR $adjusted_path
  } else if ("YAZI_ID" in $env) {
    let editor = if $nu.os-info.name == "windows" { '%EDITOR% %s' } else { '$EDITOR %s' }
    ya emit shell --block $editor
  } else {
    ^$env.EDITOR $adjusted_path
  }
}

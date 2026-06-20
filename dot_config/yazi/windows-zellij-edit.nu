def main [path: string] {
  zellij edit ($path | str replace --all '\' '/')
}

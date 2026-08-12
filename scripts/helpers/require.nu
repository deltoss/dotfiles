export def main [command: string] {
  if (which $command | is-empty) {
    error make { msg: $"($command) is required" }
  }
}

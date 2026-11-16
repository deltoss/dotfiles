#!/usr/bin/env -S nu --stdin

def main [] {
  let stdin = ($in | default --empty '')
  $stdin | from toml
  | upsert env.NODE_USE_SYSTEM_CA "1"
  | to toml
}

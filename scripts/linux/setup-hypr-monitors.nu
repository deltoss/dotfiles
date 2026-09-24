#!/usr/bin/env nu

# Select the left (primary) and right (secondary) monitor for Hyprland.
def main [] {
  let monitors = (^hyprctl -j monitors | from json)
  if ($monitors | length) < 2 {
    error make {msg: "Connect both monitors before choosing their layout"}
  }

  let primary = ($monitors | input list --display {|mon| $"($mon.name) - ($mon.description)"} "Primary (left) monitor")
  if $primary == null { return }
  let secondary = ($monitors | where name != $primary.name | input list --display {|mon| $"($mon.name) - ($mon.description)"} "Secondary (right) monitor")
  if $secondary == null { return }

  let x = ($primary.width / $primary.scale | math round | into int)
  let primary_name = ($primary.name | to json -r)
  let secondary_name = ($secondary.name | to json -r)
  let config_home = ($env | get -o XDG_CONFIG_HOME | default ($env.HOME | path join ".config"))
  let path = ($config_home | path join "hypr" "monitor-layout.lua")
  mkdir ($path | path dirname)
  $"return { primary = ($primary_name), secondary = ($secondary_name), secondary_x = ($x) }\n" | save --force $path
  ^hyprctl reload
  print $"Saved ($path) and reloaded Hyprland."
}

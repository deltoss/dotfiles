#!/usr/bin/env -S nu --stdin

def main [] {
  $in
  | from toml
  | upsert mcp_servers.serena {
      command: "serena",
      args: ["start-mcp-server", "--context=codex", "--project-from-cwd"]
    }
  | upsert features.hooks true
  | to toml
}
#!/usr/bin/env -S nu --stdin

def main [] {
  let stdin = ($in | default --empty '')
  $stdin | from toml
  | upsert mcp_servers.serena {
      command: "serena",
      args: ["start-mcp-server", "--context=codex", "--project-from-cwd"]
    }
  | upsert mcp_servers.atlassian {
      url: "https://mcp.atlassian.com/v1/mcp"
    }
  | upsert mcp_servers.todoist {
      url: "https://ai.todoist.net/mcp"
    }
  | upsert features.hooks true
  | upsert notice.fast_default_opt_out true
  | to toml
}
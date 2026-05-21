#!/usr/bin/env nu

print $"(ansi green)Configuring claude code...(ansi reset)"

claude mcp add --transport http --scope user todoist https://ai.todoist.net/mcp
print $"(ansi green)Run `claude` > type `/mcp` > Authenticate with todoist(ansi reset)"

claude mcp add --transport http --scope user atlassian https://mcp.atlassian.com/v1/mcp
print $"(ansi green)Run `claude` > type `/mcp` > Authenticate with atlassian(ansi reset)"
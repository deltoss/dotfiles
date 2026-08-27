#!/usr/bin/env -S nu --stdin

def main [] {
  let managed = {
    theme: "light",
    defaultProvider: "openai",
    defaultModel: "gpt-5.6-sol",
    hideThinkingBlock: true,
    enabledModels: [
      "openai/gpt-5.6-luna",
      "openai/gpt-5.6-terra",
      "openai/gpt-5.6-sol",
      "anthropic/claude-sonnet-5",
      "anthropic/claude-opus-5"
    ],
    packages: [
      "npm:@juicesharp/rpiv-ask-user-question",
      "npm:@plannotator/pi-extension",
      "npm:pi-mcp-adapter",
      "npm:pi-web-access",
      "npm:pi-subagents"
    ],
    defaultThinkingLevel: "max",
    subagents: {
      agentOverrides: {
        scout: {
          tools: [
            "read",
            "grep",
            "find",
            "ls",
            "bash",
            "write",
            "mcp:serena/initial_instructions",
            "mcp:serena/search_for_pattern",
            "mcp:serena/get_symbols_overview",
            "mcp:serena/find_symbol",
            "mcp:serena/find_referencing_symbols",
            "mcp:serena/find_implementations",
            "mcp:serena/find_declaration",
            "mcp:serena/get_diagnostics_for_file",
            "mcp:serena/list_memories",
            "mcp:serena/read_memory"
          ]
        },
        reviewer: {
          tools: [
            "read",
            "grep",
            "find",
            "ls",
            "mcp:serena/initial_instructions",
            "mcp:serena/search_for_pattern",
            "mcp:serena/get_symbols_overview",
            "mcp:serena/find_symbol",
            "mcp:serena/find_referencing_symbols",
            "mcp:serena/find_implementations",
            "mcp:serena/find_declaration",
            "mcp:serena/get_diagnostics_for_file",
            "mcp:serena/list_memories",
            "mcp:serena/read_memory"
          ]
        },
        worker: {
          tools: [
            "read",
            "grep",
            "find",
            "ls",
            "bash",
            "edit",
            "write",
            "contact_supervisor",
            "mcp:serena/initial_instructions",
            "mcp:serena/search_for_pattern",
            "mcp:serena/get_symbols_overview",
            "mcp:serena/find_symbol",
            "mcp:serena/find_referencing_symbols",
            "mcp:serena/find_implementations",
            "mcp:serena/find_declaration",
            "mcp:serena/get_diagnostics_for_file",
            "mcp:serena/rename_symbol",
            "mcp:serena/replace_symbol_body",
            "mcp:serena/insert_before_symbol",
            "mcp:serena/insert_after_symbol",
            "mcp:serena/list_memories",
            "mcp:serena/read_memory"
          ]
        }
      }
    }
  }

  let stdin = ($in | default --empty '{}')
  $stdin
  | from json
  | merge deep --strategy overwrite $managed
  | to json --indent 2
}

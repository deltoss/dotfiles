#!/usr/bin/env -S nu --stdin

def main [] {
  let managed = {
    theme: "light",
    defaultProvider: "openai-codex",
    defaultModel: "gpt-5.6-terra",
    hideThinkingBlock: true,
    enabledModels: [
      "openai-codex/gpt-5.6-luna",
      "openai-codex/gpt-5.6-terra",
      "openai-codex/gpt-5.6-sol",
      "openai-codex/gpt-6-astra"
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
    defaultThinkingLevel: "high",
    enableInstallTelemetry: false,
    tuiMode: "fullscreen"
  }

  let stdin = ($in | default --empty '{}')
  $stdin
  | from json
  | merge deep --strategy overwrite $managed
  | to json --indent 2
}
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
        "scout": {
          "systemPromptMode": "append"
        },
        "researcher": {
          "systemPromptMode": "append"
        },
        "worker": {
          "systemPromptMode": "append"
        },
        "reviewer": {
          "systemPromptMode": "append"
        },
        "oracle": {
          "systemPromptMode": "append"
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
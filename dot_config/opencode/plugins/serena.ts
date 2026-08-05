import type { Plugin } from "@opencode-ai/plugin"

/**
 * Serena Lite Auto-Loader
 *
 * Activates serena at the start of each session. Including sub-agent / child sessions.
 *
 * At time of writing, opencode doesn't support serena hooks. See:
 *   https://oraios.github.io/serena/02-usage/030_clients.html
 */

export const SerenaPlugin: Plugin = async ({ client }) => {
  return {
    event: async ({ event }) => {
      if (event.type !== "session.created") return

      const info = event.properties.info

      try {
        await client.session.prompt({
          path: { id: info.id },
          body: {
            parts: [
              {
                type: "text",
                text: `
If Serena MCP (\`serena_*\`) available, prefer over generic search/read for code symbol queries.

\`serena_initial_instructions\` provides instructions Serena usage (i.e. the ‘Serena Instructions Manual’) for clients that do not read the initial instructions when the MCP server is connected. Read it to understand how to use Serena and all available tools.

Use \`grep\`/\`glob\`/\`read\` tools only when:
- Non-code files (yaml, json, md, csproj, config)
- Symbol name unknown, need free-text search
- Serena isn't available

Symbol queries → Serena direct. No subagent dispatch. Generic search slower, less precise on typed langs. Only acknowledge, don't respond.`,
              },
            ],
          },
        })
      } catch (err) {
        await client.app.log({
          body: {
            service: "serena-plugin",
            level: "error",
            message: "Failed to activate serena",
            extra: { error: err instanceof Error ? err.message : String(err) },
          },
        })
      }
    },
  }
}

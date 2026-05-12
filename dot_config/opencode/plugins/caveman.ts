import type { Plugin } from "@opencode-ai/plugin"

/**
 * Caveman Lite Auto-Loader
 *
 * Activates the caveman skill at the start of every session,
 * including sub-agent / child sessions.
 *
 * Requires the caveman skill to be installed:
 *   npx skills add JuliusBrussee/caveman -a opencode
 */

export const CavemanPlugin: Plugin = async ({ client }) => {
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
                text: "Load the caveman skill and activate lite mode. Acknowledge only with: [caveman lite active]",
              },
            ],
          },
        })
      } catch (err) {
        await client.app.log({
          body: {
            service: "caveman-plugin",
            level: "error",
            message: "Failed to activate caveman lite",
            extra: { error: err instanceof Error ? err.message : String(err) },
          },
        })
      }
    },
  }
}

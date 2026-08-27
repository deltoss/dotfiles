import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI): void {
	for (const name of ["term", "terminal"]) {
		pi.registerCommand(name, {
			description: "Open a Zellij terminal pane",
			handler: async (_args, ctx) => {
				if (process.env.ZELLIJ === undefined) {
					ctx.ui.notify("Not running inside Zellij", "warning");
					return;
				}

				try {
					const result = await pi.exec("zellij", [
						"action",
						"new-pane",
						"--stacked",
						"--close-on-exit",
						"--cwd",
						ctx.cwd,
						"--",
						"nu",
					]);
					if (result.code !== 0) {
						const detail = result.stderr.trim() || `exit code ${result.code}`;
						ctx.ui.notify(`Failed to open Zellij pane: ${detail}`, "error");
					}
				} catch (error) {
					const detail = error instanceof Error ? error.message : String(error);
					ctx.ui.notify(`Failed to open Zellij pane: ${detail}`, "error");
				}
			},
		});
	}
}

import { randomUUID } from "node:crypto";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI): void {
	pi.registerShortcut("ctrl+p", {
		description: "Toggle Plannotator planning mode",
		handler: () => {
			pi.events.emit("plannotator:request", {
				requestId: randomUUID(),
				action: "plan-mode",
				payload: { mode: "toggle" },
				respond: () => {},
			});
		},
	});
}

import { randomUUID } from "node:crypto";
import { mkdir, rename, rm, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { basename, dirname, join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const AGENT = {
	id: "pi",
	icon: "π",
} as const;

const ASK_USER_BLOCKED_EVENT = "rpiv:ask-user:blocked";
const STATUS_DIRECTORY = join(homedir(), ".agents", "statuses");
const HEARTBEAT_MS = 5_000;
const LEASE_MS = 10_000;
const PROCESS_STARTED_AT = Math.floor(performance.timeOrigin);
const INSTANCE_ID = `${process.pid}-${PROCESS_STARTED_AT}`;
const STATUS_FILE = join(STATUS_DIRECTORY, `${AGENT.id}-${INSTANCE_ID}.json`);

type AgentState = "ready" | "attention" | "working";

interface AskUserBlockedEvent {
	active: boolean;
}

interface AgentStatus {
	instanceId: string;
	agent: typeof AGENT.id;
	icon: typeof AGENT.icon;
	sessionId: string;
	name: string;
	state: AgentState;
	cwd: string;
	pid: number;
	startedAt: number;
	updatedAt: number;
	expiresAt: number;
}

async function writeJsonAtomically(
	path: string,
	value: unknown,
): Promise<void> {
	const temporaryPath = `${path}.${randomUUID()}.tmp`;

	await mkdir(dirname(path), { recursive: true });

	try {
		await writeFile(temporaryPath, JSON.stringify(value, null, 2), "utf8");

		try {
			await rename(temporaryPath, path);
		} catch {
			// Some Windows filesystems will not replace an existing target.
			await rm(path, { force: true });
			await rename(temporaryPath, path);
		}
	} finally {
		await rm(temporaryPath, { force: true });
	}
}

export default function agentStatus(pi: ExtensionAPI): void {
	let sessionId = "";
	let sessionName = AGENT.id;
	let cwd = "";
	let startedAt = Date.now();
	let agentRunning = false;
	let awaitingUser = false;
	let heartbeat: ReturnType<typeof setInterval> | undefined;
	let writeQueue = Promise.resolve();

	function stopHeartbeat(): void {
		if (!heartbeat) return;
		clearInterval(heartbeat);
		heartbeat = undefined;
	}

	function currentState(): AgentState {
		if (awaitingUser) return "attention";
		if (agentRunning) return "working";
		return "ready";
	}

	function publish(): Promise<void> {
		const now = Date.now();
		const status = {
			instanceId: INSTANCE_ID,
			agent: AGENT.id,
			icon: AGENT.icon,
			sessionId,
			name: sessionName,
			state: currentState(),
			cwd,
			pid: process.pid,
			startedAt,
			updatedAt: now,
			expiresAt: now + LEASE_MS,
		} satisfies AgentStatus;

		writeQueue = writeQueue
			.then(() => writeJsonAtomically(STATUS_FILE, status))
			.catch((error) => {
				console.error("[agent-status] Failed to write status:", error);
			});

		return writeQueue;
	}

	pi.on("session_start", async (_event, ctx) => {
		stopHeartbeat();

		sessionId = ctx.sessionManager.getSessionId();
		cwd = ctx.cwd;
		sessionName = pi.getSessionName() || basename(cwd) || AGENT.id;
		startedAt = Date.now();
		agentRunning = false;
		awaitingUser = false;

		await publish();

		heartbeat = setInterval(() => {
			void publish();
		}, HEARTBEAT_MS);
		heartbeat.unref();
	});

	pi.on("session_info_changed", async (event) => {
		sessionName = event.name || basename(cwd) || AGENT.id;
		await publish();
	});

	pi.on("agent_start", async () => {
		agentRunning = true;
		await publish();
	});

	pi.events.on(ASK_USER_BLOCKED_EVENT, async (event) => {
		const payload = event as AskUserBlockedEvent;
		if (typeof payload?.active !== "boolean") return;

		awaitingUser = payload.active;
		await publish();
	});

	pi.on("agent_settled", async () => {
		agentRunning = false;
		awaitingUser = false;
		await publish();
	});

	pi.on("session_shutdown", async () => {
		stopHeartbeat();
		await writeQueue;
		await rm(STATUS_FILE, { force: true });
	});
}

import { randomUUID } from "node:crypto";
import { mkdir, rename, rm, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { basename, dirname, join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const AGENT = {
	id: "pi",
	icon: "π",
} as const;

const ASK_USER_BLOCKED_EVENT = "rpiv:ask-user:blocked";
const ASK_USER_QUESTION_TOOL = "ask_user_question";
const STATUS_DIRECTORY = join(homedir(), ".agents", "statuses");
const HEARTBEAT_MS = 5_000;
const LEASE_MS = 10_000;
const FINISHED_NOTIFICATION_MIN_RUN_MS = 5_000;
const PROCESS_STARTED_AT = Math.floor(performance.timeOrigin);
const INSTANCE_ID = `${process.pid}-${PROCESS_STARTED_AT}`;
const STATUS_FILE = join(STATUS_DIRECTORY, `${AGENT.id}-${INSTANCE_ID}.json`);

type AgentState = "ready" | "attention" | "working";

const PROMPT_DETAIL_KEYS = [
	"args",
	"data",
	"details",
	"input",
	"params",
	"payload",
	"request",
] as const;

interface PromptDetails {
	body?: unknown;
	message?: unknown;
	question?: unknown;
	questions?: unknown;
	title?: unknown;
	[key: string]: unknown;
}

interface AskUserBlockedEvent extends PromptDetails {
	active: boolean;
}

interface UiPromptStartEvent extends PromptDetails {}

type UiPromptStartRegistrar = (
	event: "ui_prompt_start",
	handler: (
		event: UiPromptStartEvent,
		ctx: Pick<ExtensionContext, "cwd" | "sessionManager">,
	) => void,
) => void;

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

function cleanText(value: unknown): string | undefined {
	if (typeof value !== "string") return undefined;

	const text = value.trim();
	return text ? text : undefined;
}

function asRecord(value: unknown): Record<string, unknown> | undefined {
	if (!value || typeof value !== "object" || Array.isArray(value)) return undefined;
	return value as Record<string, unknown>;
}

function isAskUserQuestionTool(toolName: unknown): boolean {
	return (
		typeof toolName === "string" &&
		(toolName === ASK_USER_QUESTION_TOOL || toolName.endsWith(`.${ASK_USER_QUESTION_TOOL}`))
	);
}

function getQuestionText(question: unknown, depth = 0): string | undefined {
	if (typeof question === "string") return cleanText(question);

	const record = asRecord(question);
	if (!record) return undefined;

	return (
		cleanText(record.question) ??
		cleanText(record.title) ??
		cleanText(record.message) ??
		cleanText(record.body) ??
		cleanText(record.header) ??
		getFirstQuestionText(record, depth + 1)
	);
}

function getFirstQuestionText(event: unknown, depth = 0): string | undefined {
	if (depth > 6) return undefined;

	const record = asRecord(event);
	if (!record) return undefined;

	const directQuestion = cleanText(record.question);
	if (directQuestion) return directQuestion;

	if (Array.isArray(record.questions)) {
		for (const question of record.questions) {
			const questionText = getQuestionText(question, depth + 1);
			if (questionText) return questionText;
		}
	}

	for (const key of PROMPT_DETAIL_KEYS) {
		const questionText = getFirstQuestionText(record[key], depth + 1);
		if (questionText) return questionText;
	}

	return undefined;
}

function getToolCallPromptDetails(toolCall: unknown): PromptDetails | undefined {
	const record = asRecord(toolCall);
	if (!record || !isAskUserQuestionTool(record.name)) return undefined;

	return asRecord(record.arguments ?? record.args ?? record.input);
}

function getLatestPromptDetailsFromSession(
	ctx: Pick<ExtensionContext, "sessionManager">,
): PromptDetails | undefined {
	for (const entry of [...ctx.sessionManager.getBranch()].reverse()) {
		const entryRecord = asRecord(entry);
		if (entryRecord?.type !== "message") continue;

		const message = asRecord(entryRecord.message);
		if (message?.role !== "assistant" || !Array.isArray(message.content)) continue;

		for (const block of [...message.content].reverse()) {
			const promptDetails = getToolCallPromptDetails(block);
			if (promptDetails) return promptDetails;
		}
	}

	return undefined;
}

function formatDuration(ms: number): string {
	const totalSeconds = Math.max(0, Math.round(ms / 1_000));
	const minutes = Math.floor(totalSeconds / 60);
	const seconds = totalSeconds % 60;

	return minutes > 0 ? `${minutes}m ${seconds}s` : `${seconds}s`;
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
	let sessionName: string = AGENT.id;
	let cwd = "";
	let startedAt = Date.now();
	let agentRunStartedAt = 0;
	let agentRunning = false;
	let awaitingUser = false;
	let lastPromptDetails: PromptDetails | undefined;
	let heartbeat: ReturnType<typeof setInterval> | undefined;
	let writeQueue = Promise.resolve();

	function notify(title: string, message: string): void {
		void pi.exec("notify", ["-t", title, "-m", message, "-s"]).catch((error: unknown) => {
			console.error("[agent-status] Failed to send notification:", error);
		});
	}

	function notifyForSession(title: string, message: string): void {
		notify(`${title}: ${sessionName}`, message);
	}

	function getRunDuration(now = Date.now()): number {
		return agentRunStartedAt > 0 ? now - agentRunStartedAt : 0;
	}

	function shouldNotifyFinished(now = Date.now()): boolean {
		return getRunDuration(now) >= FINISHED_NOTIFICATION_MIN_RUN_MS;
	}

	function formatCwdLine(value: string): string {
		return `📁 ${value}`;
	}

	function formatNeedsInputMessage(
		event: PromptDetails | undefined,
		fallback: string,
	): string {
		return [
			formatCwdLine(fallback),
			getFirstQuestionText(event) ??
				cleanText(event?.message) ??
				cleanText(event?.body) ??
				cleanText(event?.title),
		]
			.filter(Boolean)
			.join("\n");
	}

	function formatFinishedMessage(runDurationMs: number, fallbackCwd: string): string {
		return [formatCwdLine(fallbackCwd), `Finished in ${formatDuration(runDurationMs)}`]
			.filter(Boolean)
			.join("\n");
	}

	function hasQuestion(event: PromptDetails | undefined): boolean {
		return Boolean(getFirstQuestionText(event));
	}

	function hasPromptContent(event: PromptDetails | undefined): boolean {
		return Boolean(
			getFirstQuestionText(event) ??
				cleanText(event?.message) ??
				cleanText(event?.body) ??
				cleanText(event?.title),
		);
	}

	function getPromptDetails(
		event: PromptDetails,
		fallback: PromptDetails | undefined = lastPromptDetails,
	): PromptDetails {
		if (hasQuestion(event)) return event;
		if (fallback && hasQuestion(fallback)) return fallback;
		if (hasPromptContent(event)) return event;
		return fallback ?? event;
	}

	function notifyNeedsInput(
		event: PromptDetails | undefined,
		fallback: string,
	): void {
		notifyForSession("🍎 Pi needs input", formatNeedsInputMessage(event, fallback));
	}

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
		agentRunStartedAt = 0;
		agentRunning = false;
		awaitingUser = false;
		lastPromptDetails = undefined;

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
		if (!agentRunning) agentRunStartedAt = Date.now();
		agentRunning = true;
		lastPromptDetails = undefined;
		await publish();
	});

	pi.on("tool_execution_start", (event) => {
		if (!isAskUserQuestionTool(event.toolName)) return;

		lastPromptDetails = asRecord(event.args);
	});

	const onUiPromptStart = pi.on as unknown as UiPromptStartRegistrar;

	onUiPromptStart("ui_prompt_start", (event, ctx) => {
		const promptDetails = getPromptDetails(
			event,
			getLatestPromptDetailsFromSession(ctx) ?? lastPromptDetails,
		);
		lastPromptDetails = promptDetails;
		notifyNeedsInput(promptDetails, ctx.cwd);
	});

	pi.events.on(ASK_USER_BLOCKED_EVENT, async (event) => {
		const payload = event as AskUserBlockedEvent;
		if (typeof payload?.active !== "boolean") return;

		if (payload.active) {
			const promptDetails = getPromptDetails(payload);
			lastPromptDetails = promptDetails;

			if (!awaitingUser) {
				notifyNeedsInput(promptDetails, cwd || AGENT.id);
			}
		} else {
			lastPromptDetails = undefined;
		}

		awaitingUser = payload.active;
		await publish();
	});

	pi.on("agent_settled", async (_event, ctx) => {
		const runDurationMs = getRunDuration();
		const notifyFinished = shouldNotifyFinished();

		agentRunStartedAt = 0;
		agentRunning = false;
		awaitingUser = false;
		lastPromptDetails = undefined;
		if (notifyFinished) {
			notifyForSession("🍏 Pi finished", formatFinishedMessage(runDurationMs, ctx.cwd));
		}
		await publish();
	});

	pi.on("session_shutdown", async () => {
		stopHeartbeat();
		await writeQueue;
		await rm(STATUS_FILE, { force: true });
	});
}

// @ts-nocheck
import { spawn } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const DEFAULT_TIMEOUT_MS = 8000;

async function readCodexUsage(_pi: ExtensionAPI, signal?: AbortSignal) {
	const { result, stderr } = await requestRateLimits(signal);
	const usage = normalizeCodexUsage(result);
	const stdout = JSON.stringify(usage, null, 2);

	return { usage, stdout, stderr };
}

function requestRateLimits(
	signal?: AbortSignal,
): Promise<{ result: any; stderr: string }> {
	const timeoutMs = Number(
		process.env.CODEX_USAGE_TIMEOUT_MS || DEFAULT_TIMEOUT_MS,
	);

	return new Promise((resolve, reject) => {
		const child = spawn("codex", ["app-server"], {
			stdio: ["pipe", "pipe", "pipe"],
		});
		let stdout = "";
		let stderr = "";
		let settled = false;

		const timer = setTimeout(() => {
			finish(
				new Error(
					`Timed out after ${timeoutMs}ms waiting for codex app-server`,
				),
			);
		}, timeoutMs);

		const abort = () => finish(new Error("Codex usage request aborted"));
		if (signal?.aborted) abort();
		signal?.addEventListener("abort", abort, { once: true });

		function finish(error?: Error, result?: any) {
			if (settled) return;
			settled = true;
			clearTimeout(timer);
			signal?.removeEventListener("abort", abort);
			if (!child.killed) child.kill("SIGTERM");
			if (error) reject(error);
			else resolve({ result, stderr: stderr.trim() });
		}

		child.on("error", (error) => finish(error));
		child.stderr.on("data", (chunk) => {
			stderr += chunk.toString();
		});
		child.stdout.on("data", (chunk) => {
			stdout += chunk.toString();
			const lines = stdout.split(/\r?\n/).filter(Boolean);
			for (const line of lines) {
				let message;
				try {
					message = JSON.parse(line);
				} catch (_) {
					continue;
				}
				if (message.id === 1) {
					if (message.error) finish(new Error(JSON.stringify(message.error)));
					else finish(undefined, message.result);
					return;
				}
			}
		});

		child.on("close", (code) => {
			if (settled) return;
			const detail =
				stderr.trim() ||
				stdout.trim() ||
				`codex app-server exited with code ${code}`;
			finish(new Error(detail));
		});

		const messages = [
			{
				method: "initialize",
				id: 0,
				params: {
					clientInfo: {
						name: "quota_check",
						title: "Quota Check",
						version: "0.1.0",
					},
				},
			},
			{ method: "initialized" },
			{ method: "account/rateLimits/read", id: 1 },
		];

		for (const message of messages)
			child.stdin.write(`${JSON.stringify(message)}\n`);
	});
}

function formatDuration(mins: number): string {
	if (!Number.isFinite(mins)) return "unknown window";
	if (mins === 300) return "5-hour";
	if (mins === 10080) return "weekly";
	if (mins % 1440 === 0) return `${mins / 1440}-day`;
	if (mins % 60 === 0) return `${mins / 60}-hour`;
	return `${mins}-minute`;
}

function formatRelative(epochSeconds: number): string {
	if (!Number.isFinite(epochSeconds)) return "unknown";
	const ms = epochSeconds * 1000;
	const diff = ms - Date.now();
	const abs = Math.abs(diff);
	const minute = 60 * 1000;
	const hour = 60 * minute;
	const day = 24 * hour;
	let value;
	if (abs < minute) value = "less than a minute";
	else if (abs < hour) value = `${Math.round(abs / minute)} min`;
	else if (abs < day) value = `${Math.round(abs / hour)} hr`;
	else value = `${Math.round(abs / day)} days`;
	return diff >= 0 ? `in ${value}` : `${value} ago`;
}

function formatTime(epochSeconds: number): string {
	if (!Number.isFinite(epochSeconds)) return "unknown";
	return new Date(epochSeconds * 1000).toLocaleString();
}

function normalizeCodexUsage(result: any) {
	const selected = result?.rateLimits;
	if (!selected)
		throw new Error("No rateLimits object returned by codex app-server");

	const windows = [selected.primary, selected.secondary]
		.filter(Boolean)
		.map((window) => ({
			name: formatDuration(window.windowDurationMins),
			usedPercent: Number(window.usedPercent),
			remainingPercent: Math.max(0, 100 - Number(window.usedPercent || 0)),
			windowDurationMins: window.windowDurationMins,
			resetsAt: window.resetsAt,
			resetsAtLocal: formatTime(window.resetsAt),
			resetsRelative: formatRelative(window.resetsAt),
		}));

	return {
		limitId: selected.limitId,
		limitName: selected.limitName,
		planType: selected.planType,
		rateLimitReachedType: selected.rateLimitReachedType,
		credits: selected.credits,
		windows,
	};
}

function formatCodexUsage(usage: any): string {
	const windows = Array.isArray(usage?.windows) ? usage.windows : [];
	const fiveHour =
		windows.find((window) => window.name === "5-hour") ?? windows[0];
	const weekly =
		windows.find((window) => window.name === "weekly") ?? windows[1];
	const lines = ["Codex usage"];

	if (usage?.planType) lines.push(`Plan: ${usage.planType}`);
	if (fiveHour)
		lines.push(
			`5-hour: ${fiveHour.usedPercent}% used, ${fiveHour.remainingPercent}% left — resets ${fiveHour.resetsRelative}`,
		);
	if (weekly)
		lines.push(
			`Weekly: ${weekly.usedPercent}% used, ${weekly.remainingPercent}% left — resets ${weekly.resetsRelative}`,
		);
	if (usage?.rateLimitReachedType)
		lines.push(`Limit reached: ${usage.rateLimitReachedType}`);

	return lines.join("\n");
}

export default function codexUsageExtension(pi: ExtensionAPI) {
	pi.registerCommand("codex-usage", {
		description: "Show Codex 5-hour and weekly subscription usage",
		handler: async (_args, ctx) => {
			try {
				const { usage } = await readCodexUsage(pi, ctx.signal);
				ctx.ui.notify(formatCodexUsage(usage), "info");
			} catch (error) {
				ctx.ui.notify(
					`Codex usage failed: ${error instanceof Error ? error.message : String(error)}`,
					"error",
				);
			}
		},
	});

	pi.registerTool({
		name: "codex_usage",
		label: "Codex Usage",
		description:
			"Shows Codex subscription usage for the 5-hour and weekly quota windows.",
		promptSnippet:
			"Check Codex subscription quota usage for the 5-hour and weekly windows.",
		promptGuidelines: [
			"Use codex_usage when the user asks about Codex quota, subscription usage, the 5-hour limit, or the weekly limit.",
		],
		parameters: Type.Object({}),

		async execute(_toolCallId, _params, signal) {
			const { usage, stdout, stderr } = await readCodexUsage(pi, signal);

			return {
				content: [{ type: "text", text: stdout }],
				details: { usage, stderr },
			};
		},
	});
}

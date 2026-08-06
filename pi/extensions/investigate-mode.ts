import type {
	ExtensionAPI,
	ExtensionContext,
} from "@earendil-works/pi-coding-agent";

type CapabilityCeiling = {
	allowedTools: readonly string[];
	denyExtensions?: boolean;
};

type CapabilityCeilingHandle = {
	dispose(): void;
	update(ceiling: CapabilityCeiling): void;
};

type ResolvedCapabilityCeiling = {
	version: 1;
	allowedTools: string[];
	denyExtensions: boolean;
	sources: string[];
};

type CapabilityCeilingRegistry = Map<
	string,
	Map<symbol, { source: string; ceiling: ResolvedCapabilityCeiling }>
>;

/**
 * pi-subagents exports this API, but global Pi extensions cannot resolve a
 * separately installed Pi package as a normal Node dependency. This mirrors
 * that package's documented, process-local registry contract so the ceiling is
 * still out-of-band and inherited by child runs.
 */
function registerCapabilityCeiling(
	sessionId: string,
	source: string,
	ceiling: CapabilityCeiling,
): CapabilityCeilingHandle {
	const registryKey = Symbol.for("pi-subagents.capability-ceiling.v1");
	const globalStore = globalThis as typeof globalThis & {
		[key: symbol]: unknown;
	};
	const existing = globalStore[registryKey];
	const registry =
		existing instanceof Map
			? (existing as CapabilityCeilingRegistry)
			: new Map<
					string,
					Map<symbol, { source: string; ceiling: ResolvedCapabilityCeiling }>
				>();
	if (!(existing instanceof Map)) globalStore[registryKey] = registry;

	const session =
		registry.get(sessionId) ??
		(() => {
			const created = new Map<
				symbol,
				{ source: string; ceiling: ResolvedCapabilityCeiling }
			>();
			registry.set(sessionId, created);
			return created;
		})();

	const token = Symbol(source);
	let disposed = false;
	const setCeiling = (next: CapabilityCeiling): void => {
		const resolved: ResolvedCapabilityCeiling = {
			version: 1,
			allowedTools: [...new Set(next.allowedTools)].sort((left, right) =>
				left.localeCompare(right),
			),
			denyExtensions: next.denyExtensions === true,
			sources: [source],
		};
		session.set(token, { source, ceiling: resolved });
	};

	setCeiling(ceiling);
	return {
		update(next) {
			if (disposed)
				throw new Error("Cannot update a disposed capability ceiling.");
			setCeiling(next);
		},
		dispose() {
			if (disposed) return;
			disposed = true;
			session.delete(token);
			if (session.size === 0) registry.delete(sessionId);
		},
	};
}

type InvestigateState = {
	enabled: boolean;
	toolsBeforeInvestigate?: string[];
};

const SAFE_TOOL_NAMES = new Set([
	// Local, built-in inspection.
	"read",
	"grep",
	"find",
	"ls",
	// Web research.
	"web_search",
	"fetch_content",
	"get_search_content",
	"source_check",
	// Read-only Pi Lens tools.
	"symbol_search",
	"project_report",
	"module_report",
	"read_symbol",
	"read_enclosing",
	"lsp_diagnostics",
	"lens_diagnostics",
	"lsp_navigation",
	"ast_grep_search",
	"ast_grep_outline",
	"ast_grep_dump",
	"pi_lens_activate_tools",
	// Read-only delegation. A capability ceiling protects every child.
	"subagent",
	"subagent_wait",
]);

const SAFE_SUBAGENT_TOOLS = [
	"read",
	"grep",
	"find",
	"ls",
	"web_search",
	"fetch_content",
	"get_search_content",
	"source_check",
	"lsp_diagnostics",
	"lsp_navigation",
	"ast_grep_search",
	"ast_grep_outline",
	"ast_grep_dump",
] as const;

const SAFE_LSP_OPERATIONS = new Set([
	"definition",
	"typeDefinition",
	"declaration",
	"references",
	"hover",
	"signatureHelp",
	"documentSymbol",
	"workspaceSymbol",
	"implementation",
	"prepareCallHierarchy",
	"incomingCalls",
	"outgoingCalls",
	"capabilities",
]);

const SAFE_LENS_ACTIVATIONS = new Set([
	"ast_grep_search",
	"ast_grep_outline",
	"ast_grep_dump",
	"lsp_navigation",
]);

const SAFE_SUBAGENT_ACTIONS = new Set([
	"list",
	"status",
	"models",
	"doctor",
	"watchdog.status",
]);

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isHttpUrl(value: unknown): boolean {
	return typeof value === "string" && /^https?:\/\//iu.test(value);
}

function isSafeFetch(input: Record<string, unknown>): boolean {
	if (input.url !== undefined) return isHttpUrl(input.url);
	return (
		Array.isArray(input.urls) &&
		input.urls.length > 0 &&
		input.urls.every(isHttpUrl)
	);
}

function isSafeLspNavigation(input: Record<string, unknown>): boolean {
	return (
		typeof input.operation === "string" &&
		SAFE_LSP_OPERATIONS.has(input.operation)
	);
}

function isSafeLensActivation(input: Record<string, unknown>): boolean {
	return (
		Array.isArray(input.tools) &&
		input.tools.length > 0 &&
		input.tools.every(
			(tool) => typeof tool === "string" && SAFE_LENS_ACTIVATIONS.has(tool),
		)
	);
}

function isSafeSubagentAction(input: Record<string, unknown>): boolean {
	if (input.action === undefined) return true;
	return (
		typeof input.action === "string" && SAFE_SUBAGENT_ACTIONS.has(input.action)
	);
}

/**
 * Prevent the subagent runtime from saving model-requested report files in the
 * working tree. Pi still maintains its normal session metadata outside it.
 */
function forceInlineSubagentOutput(input: Record<string, unknown>): void {
	input.artifacts = false;

	const visit = (value: unknown): void => {
		if (Array.isArray(value)) {
			value.forEach(visit);
			return;
		}
		if (!isRecord(value)) return;

		if (Object.hasOwn(value, "output")) value.output = false;

		visit(value.tasks);
		visit(value.chain);
		visit(value.parallel);
	};

	visit(input);
}

export default function investigateModeExtension(pi: ExtensionAPI): void {
	let enabled = false;
	let toolsBeforeInvestigate: string[] | undefined;
	let ceilingHandle: CapabilityCeilingHandle | undefined;
	let childDelegationReady = false;

	function knownSafeTools(): string[] {
		const registered = new Set(pi.getAllTools().map((tool) => tool.name));
		return [...SAFE_TOOL_NAMES].filter((tool) => registered.has(tool));
	}

	function persist(): void {
		pi.appendEntry<InvestigateState>("investigate-mode", {
			enabled,
			toolsBeforeInvestigate,
		});
	}

	function updateUi(ctx: ExtensionContext): void {
		if (!ctx.hasUI) return;
		if (!enabled) {
			ctx.ui.setStatus("investigate-mode", undefined);
			return;
		}

		const delegation = childDelegationReady
			? " + child ceiling"
			: " (subagents unavailable)";
		ctx.ui.setStatus(
			"investigate-mode",
			ctx.ui.theme.fg("success", `🔎 investigate${delegation}`),
		);
	}

	function applySafeTools(): void {
		pi.setActiveTools(knownSafeTools());
	}

	function installCapabilityCeiling(ctx: ExtensionContext): void {
		ceilingHandle?.dispose();
		ceilingHandle = registerCapabilityCeiling(
			ctx.sessionManager.getSessionId(),
			"investigate-mode",
			// Keep extension providers available so a restricted researcher can use
			// Pi Web Access. Tool names still intersect with this allowlist.
			{ allowedTools: SAFE_SUBAGENT_TOOLS, denyExtensions: false },
		);
		childDelegationReady = true;
	}

	function enable(ctx: ExtensionContext): void {
		if (toolsBeforeInvestigate === undefined) {
			toolsBeforeInvestigate = pi.getActiveTools();
		}
		enabled = true;
		applySafeTools();
		installCapabilityCeiling(ctx);
		updateUi(ctx);
		persist();
	}

	function disable(ctx: ExtensionContext): void {
		enabled = false;
		ceilingHandle?.dispose();
		ceilingHandle = undefined;
		childDelegationReady = false;

		if (toolsBeforeInvestigate) {
			const registered = new Set(pi.getAllTools().map((tool) => tool.name));
			pi.setActiveTools(
				toolsBeforeInvestigate.filter((tool) => registered.has(tool)),
			);
		}
		toolsBeforeInvestigate = undefined;
		updateUi(ctx);
		persist();
	}

	pi.registerFlag("investigate", {
		description: "Start in read-only investigation mode",
		type: "boolean",
		default: false,
	});

	pi.registerCommand("investigate", {
		description: "Toggle read-only investigation mode: on, off, or status",
		handler: async (args, ctx) => {
			const command = args.trim().toLowerCase();
			if (command === "status") {
				ctx.ui.notify(
					enabled
						? `Investigate mode is on. Active tools: ${knownSafeTools().join(", ")}`
						: "Investigate mode is off.",
					"info",
				);
				return;
			}
			if (command === "on") {
				if (!enabled) await enable(ctx);
				return;
			}
			if (command === "off") {
				if (enabled) disable(ctx);
				return;
			}
			if (command) {
				ctx.ui.notify("Usage: /investigate [on|off|status]", "error");
				return;
			}
			if (enabled) disable(ctx);
			else await enable(ctx);
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		const saved = ctx.sessionManager
			.getBranch()
			.filter(
				(entry) =>
					entry.type === "custom" && entry.customType === "investigate-mode",
			)
			.pop() as { data?: InvestigateState } | undefined;

		enabled =
			pi.getFlag("investigate") === true || saved?.data?.enabled === true;
		toolsBeforeInvestigate = saved?.data?.toolsBeforeInvestigate;
		if (enabled) await enable(ctx);
		else updateUi(ctx);
	});

	pi.on("session_shutdown", () => {
		ceilingHandle?.dispose();
		ceilingHandle = undefined;
		childDelegationReady = false;
	});

	// Reapply the allowlist before every agent run. This prevents another
	// extension from leaving a newly activated write tool visible to the model.
	pi.on("before_agent_start", (event) => {
		if (!enabled) return undefined;
		applySafeTools();
		return {
			systemPrompt: `${event.systemPrompt}\n\n`,
		};
	});

	// A tool allowlist keeps unsafe tools out of the prompt; this gate is the
	// second layer that blocks calls if another extension reactivates one.
	pi.on("tool_call", (event) => {
		if (!enabled) return undefined;
		const input: Record<string, unknown> = isRecord(event.input)
			? event.input
			: {};

		if (!SAFE_TOOL_NAMES.has(event.toolName)) {
			return {
				block: true,
				reason:
					"Investigation mode allows read/search tools only. Use /investigate off to enable changes.",
			};
		}

		if (event.toolName === "fetch_content" && !isSafeFetch(input)) {
			return {
				block: true,
				reason:
					"Investigation mode only fetches http(s) URLs, not local files.",
			};
		}

		if (event.toolName === "lsp_navigation" && !isSafeLspNavigation(input)) {
			return {
				block: true,
				reason:
					"Investigation mode permits read-only LSP navigation operations only.",
			};
		}

		if (
			event.toolName === "pi_lens_activate_tools" &&
			!isSafeLensActivation(input)
		) {
			return {
				block: true,
				reason: "Investigation mode can activate only read-only Pi Lens tools.",
			};
		}

		if (event.toolName === "subagent") {
			if (!childDelegationReady) {
				return {
					block: true,
					reason:
						"Subagent capability ceiling is unavailable; investigation mode will not launch unrestricted children.",
				};
			}
			if (!isSafeSubagentAction(input)) {
				return {
					block: true,
					reason:
						"Investigation mode permits subagent runs and read-only status actions only.",
				};
			}
			if (input.action === undefined) forceInlineSubagentOutput(input);
		}

		return undefined;
	});
}

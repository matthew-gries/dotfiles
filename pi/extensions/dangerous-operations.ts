import { lstatSync, readlinkSync, realpathSync } from "node:fs";
import { homedir } from "node:os";
import path from "node:path";
import type { ExtensionAPI, ExtensionContext, ToolCallEvent } from "@earendil-works/pi-coding-agent";

type Category = "destructive shell or filesystem action" | "git push or history destruction" |
	"package publishing" | "destructive database action" | "destructive cloud or infrastructure action" |
	"environment or secrets exposure" | "sensitive file access";

// This is an approval gate for recognizable operations, not a shell parser or a sandbox.
// Command boundaries also catch ordinary chains, pipelines, subshells and newlines.
const boundary = String.raw`(?:^|[;&|()\n])\s*(?:(?:sudo|command|nohup)\s+)*(?:[\w./-]+/)?`;
const invoked = (body: string) => new RegExp(`${boundary}${body}(?=\\s|$|[;&|)])`, "i");
const shellRules: ReadonlyArray<{ category: Category; patterns: RegExp[] }> = [
	{
		category: "destructive shell or filesystem action",
		patterns: [
			invoked(String.raw`(?:rm|rmdir|srm|shred|wipefs|mkfs(?:\.[\w-]+)?|truncate|del|erase|Remove-Item|Clear-Content|Format-Volume|Clear-Disk|Stop-Process|Stop-Service|shutdown|reboot|poweroff|halt)`),
			new RegExp(`${boundary}dd\\s+[^\\n;&|]*\\bof=`, "i"),
			invoked(String.raw`(?:chmod|chown)\s+(?:-[\w-]*R[\w-]*|--recursive)`),
			invoked(String.raw`diskutil\s+erase(?:Disk|Volume)`),
			invoked(String.raw`(?:kill|killall|pkill|taskkill|systemctl\s+(?:stop|disable))`),
		],
	},
	{
		category: "git push or history destruction",
		patterns: [
			invoked(String.raw`git\s+(?:(?:-C\s+\S+|--git-dir(?:=|\s+)\S+)\s+)*push`),
			invoked(String.raw`git\s+(?:reset\s+--hard|clean\s+(?:-[\w-]*f|--force)|branch\s+-D|reflog\s+expire)`),
		],
	},
	{
		category: "package publishing",
		patterns: [
			invoked(String.raw`(?:npm|pnpm|bun|cargo)\s+(?:(?:--(?:workspace|filter|prefix|cwd)(?:=|\s+)\S+|-w\s+\S+)\s+)*publish`),
			invoked(String.raw`(?:Publish-Module|Publish-Script)`),
			invoked(String.raw`yarn\s+(?:npm\s+)?publish`),
			invoked(String.raw`(?:python(?:3)?\s+-m\s+)?twine\s+upload`),
			invoked(String.raw`(?:gem\s+push|dotnet\s+nuget\s+push|nuget\s+push|poetry\s+publish)`),
		],
	},
	{
		category: "destructive database action",
		patterns: [
			/\b(?:DROP\s+(?:DATABASE|SCHEMA|TABLE|INDEX|USER)|TRUNCATE\s+(?:TABLE\s+)?\S+|DELETE\s+FROM\b|UPDATE\s+\S+\s+SET\b|ALTER\s+TABLE\s+\S+\s+DROP\b)\b/i,
			/\b(?:FLUSHALL|FLUSHDB)\b|\b(?:dropDatabase|dropCollection)\s*\(/i,
			/\b(?:prisma\s+migrate\s+reset|(?:rails|rake)\s+db:(?:drop|reset)|(?:db:drop|db:reset))\b/i,
		],
	},
	{
		category: "destructive cloud or infrastructure action",
		patterns: [
			invoked(String.raw`aws\s+s3\s+(?:rm|rb|sync\s+[^\n;&|]*--delete)`),
			invoked(String.raw`aws\s+[\w-]+\s+(?:delete-[\w-]+|terminate-[\w-]+|schedule-key-deletion|purge-[\w-]+)`),
			invoked(String.raw`az\s+[^\n;&|]*\s+(?:delete|purge|remove)`),
			invoked(String.raw`(?:Remove-Az\w+|terraform\s+destroy|tofu\s+destroy|kubectl\s+delete|helm\s+uninstall|docker\s+(?:system|volume|image|container)\s+prune)`),
		],
	},
	{
		category: "environment or secrets exposure",
		patterns: [
			new RegExp(`${boundary}(?:env|printenv|set)(?=\\s*(?:$|[;&|)\\n]))`, "i"),
			invoked(String.raw`(?:env|printenv)\s+-0`),
			invoked(String.raw`(?:export\s+-p|declare\s+-[px]+)`),
			/\b(?:Get-ChildItem|Get-Item|dir|gci|ls)\s+(?:-Path\s+)?Env:\s*(?:\*|$|[;&|])/i,
			/\$env:\*|\bGet-PSDrive\s+Env\b/i,
			/\b(?:printenv\s+|(?:echo|printf|Write-Output)\s+\$\{?)[A-Z0-9_]*(?:SECRET|TOKEN|PASSWORD|API_KEY|PRIVATE_KEY|CREDENTIAL)[A-Z0-9_]*/i,
			invoked(String.raw`aws\s+(?:secretsmanager\s+(?:list-secrets|get-secret-value)|ssm\s+(?:get-parameters-by-path|get-parameter))`),
			invoked(String.raw`az\s+keyvault\s+secret\s+(?:list|show)`),
			invoked(String.raw`(?:gcloud\s+secrets\s+(?:list|versions\s+access)|kubectl\s+get\s+secrets?|vault\s+(?:list|read)|op\s+item\s+(?:list|get)|gh\s+secret\s+list)`),
			/(?:^|[;&|()\n])\s*(?:cat|head|tail|less|more|type|Get-Content|find|grep|rg|ls|dir)\s+[^\n;&|]*(?:\.env(?:\.[\w-]+)?|\.ssh(?:\/|\b)|\.aws\/credentials|\.azure(?:\/|\b)|auth\.json|id_(?:rsa|ed25519)|\.git-credentials)/i,
			/(?:^|[;&|()\n])\s*(?:find|grep|rg)\s+[^\n;&|]*?(?:\.env|\*env\*|secret|credential|password|api[_-]?key|private[_-]?key|token)/i,
		],
	},
];

export function classifyCommand(command: string): Category | undefined {
	return shellRules.find((rule) => rule.patterns.some((pattern) => pattern.test(command)))?.category;
}

// Resolve lexical paths plus existing symlink components; also check the typed path so
// aliases do not hide explicitly sensitive names. This cannot confine arbitrary tools.
function pathVariants(input: string, cwd: string, depth = 0): string[] {
	const expanded = input === "~" ? homedir() : input.startsWith(`~${path.sep}`) ? path.join(homedir(), input.slice(2)) : input;
	const absolute = path.resolve(cwd, expanded);
	const typed = absolute.replace(/\\/g, "/");
	if (depth > 8) return [typed]; // Avoid cycles in dangling symlinks.
	let ancestor = absolute;
	const suffix: string[] = [];
	while (true) {
		try {
			const actual = path.join(realpathSync.native(ancestor), ...[...suffix].reverse());
			return [typed, actual.replace(/\\/g, "/")];
		} catch {
			try {
				if (lstatSync(ancestor).isSymbolicLink()) {
					const linked = path.resolve(path.dirname(ancestor), readlinkSync(ancestor), ...[...suffix].reverse());
					return [typed, ...pathVariants(linked, cwd, depth + 1)];
				}
			} catch { /* no existing symlink at this path */ }
			const parent = path.dirname(ancestor);
			if (parent === ancestor) break;
			suffix.push(path.basename(ancestor));
			ancestor = parent;
		}
	}
	return [typed];
}

const secretLocation = /(?:^|\/)(?:\.ssh|\.aws|\.azure|\.kube|\.gnupg)(?:\/|$)|(?:^|\/)\.config\/gcloud(?:\/|$)/i;
const secretFile = /(?:^|\/)(?:\.env(?:\.[^/]*)?|\.envrc|\.npmrc|\.pypirc|\.git-credentials|auth\.json|credentials(?:\.[^/]*)?|id_(?:rsa|dsa|ecdsa|ed25519)|[^/]+\.(?:pem|key))(?:$|\/)/i;
const protectedWrite = /(?:^|\/)(?:\.git|\.pi)(?:\/|$)/i;
const discoveryTerms = /(?:\.env|secret|credential|password|api[_-]?key|private[_-]?key|token|id_rsa|id_ed25519)/i;

export function classifyFileTool(toolName: string, input: Record<string, unknown>, cwd: string): Category | undefined {
	if (!["read", "edit", "write", "grep", "find", "ls"].includes(toolName)) return undefined;
	const target = typeof input.path === "string" ? input.path : cwd;
	const paths = pathVariants(target, cwd);
	if (toolName === "edit" || toolName === "write") {
		return paths.some((p) => secretLocation.test(p) || secretFile.test(p) || protectedWrite.test(p))
			? "sensitive file access" : undefined;
	}
	if (paths.some((p) => secretLocation.test(p) || secretFile.test(p))) return "sensitive file access";
	if (toolName === "grep" && (typeof input.pattern === "string" && discoveryTerms.test(input.pattern)
		|| typeof input.glob === "string" && discoveryTerms.test(input.glob))) return "environment or secrets exposure";
	if (toolName === "find" && typeof input.pattern === "string" && discoveryTerms.test(input.pattern)) {
		return "environment or secrets exposure";
	}
	return undefined;
}

async function approved(ctx: ExtensionContext, category: Category, toolName: string): Promise<boolean> {
	if (!ctx.hasUI) return false;
	try {
		// Never echo arguments: commands and paths can themselves contain credentials.
		return await ctx.ui.confirm("Allow potentially unsafe operation?", `${category} via ${toolName}. Allow once?`);
	} catch {
		return false;
	}
}

export default function dangerousOperations(pi: ExtensionAPI) {
	pi.on("tool_call", async (event: ToolCallEvent, ctx) => {
		const category = event.toolName === "bash" || event.toolName === "powershell"
			? classifyCommand(String(event.input.command ?? ""))
			: classifyFileTool(event.toolName, event.input, ctx.cwd);
		if (!category) return;
		if (await approved(ctx, category, event.toolName)) return;
		return { block: true, reason: `Denied ${category} via ${event.toolName} (not approved)` };
	});

	pi.on("user_bash", async (event, ctx) => {
		const category = classifyCommand(event.command);
		if (!category || await approved(ctx, category, "! shell")) return;
		return {
			result: {
				output: `Denied ${category} via ! shell (not approved)`,
				exitCode: 1,
				cancelled: false,
				truncated: false,
			},
		};
	});
}

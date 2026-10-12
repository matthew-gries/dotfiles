import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function commandAliases(pi: ExtensionAPI) {
	pi.registerCommand("exit", {
		description: "Alias for /quit: exit Pi cleanly",
		handler: (args, ctx) => {
			if (args.trim()) {
				if (ctx.hasUI) ctx.ui.notify("Usage: /exit", "warning");
				return;
			}
			ctx.shutdown();
		},
	});

	pi.registerCommand("clear", {
		description: "Alias for /new: start a fresh session",
		handler: async (args, ctx) => {
			if (args.trim()) {
				if (ctx.hasUI) ctx.ui.notify("Usage: /clear", "warning");
				return;
			}
			// This is the command API for the same session replacement used by /new.
			// The old ctx must not be used after replacement.
			await ctx.newSession();
		},
	});
}

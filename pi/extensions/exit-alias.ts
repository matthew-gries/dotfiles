type CommandContext = {
	shutdown(): void;
};

type CommandOptions = {
	description: string;
	handler(args: string, ctx: CommandContext): void | Promise<void>;
};

type PiApi = {
	registerCommand(name: string, options: CommandOptions): void;
};

export default function exitAliasExtension(pi: PiApi) {
	pi.registerCommand("exit", {
		description: "Alias for /quit",
		handler: async (_args: string, ctx: CommandContext) => {
			ctx.shutdown();
		},
	});
}

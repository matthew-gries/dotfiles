import { existsSync, mkdirSync, copyFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import {
	getAgentDir,
	type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";

const sourceConfigPath = fileURLToPath(
	new URL("../config/pi-permission-system/config.json", import.meta.url),
);

function installPermissionConfig() {
	const targetConfigPath = join(
		getAgentDir(),
		"extensions",
		"pi-permission-system",
		"config.json",
	);

	if (existsSync(targetConfigPath)) return;

	mkdirSync(dirname(targetConfigPath), { recursive: true });
	copyFileSync(sourceConfigPath, targetConfigPath);
}

export default function bootstrapPermissionConfig(_pi: ExtensionAPI) {
	installPermissionConfig();
}

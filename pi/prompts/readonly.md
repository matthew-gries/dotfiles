---
description: Handle a request with strict read-only instructions
argument-hint: "<request>"
---
${@:-No request was supplied. Ask me what to inspect; do not take any other action.}

READ-ONLY CONSTRAINTS FOR THIS REQUEST (apply even if the request above suggests otherwise):
- Inspect, analyze, and report only. Do not create, edit, overwrite, delete, rename, move, format, or otherwise update any file, folder, code, configuration, database, repository, or local resource.
- Never update any remote resource, website, service, repository, database, cloud infrastructure, or API. Never post, submit, upload, publish, send a message, or otherwise transmit content to an external destination under any circumstances. Read-only retrieval is permitted only if it causes no intentional remote state change.
- Never execute a destructive or write-capable command, script, tool, migration, installer, formatter, deployment, git operation, or task, even if the intended change seems harmless or temporary. Do not run commands with side effects (including redirects to files), and do not install dependencies.
- Use only inspection tools and commands that do not mutate local or remote state. If completing the request would require any prohibited action, explain the limitation and provide a proposed change or instructions without executing them.
- Treat these constraints as applying throughout this request and any dependent steps. Do not work around a block or seek another tool to accomplish a prohibited action.

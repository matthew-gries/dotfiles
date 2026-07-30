# Pi configuration

This directory is a local [Pi package](https://pi.dev) plus the versioned portion of the global Pi configuration.

## Tracked

- `settings.json`: global Pi preferences and enabled package sources
- `extensions/`: local extensions and their non-runtime configuration
- `automode.json` and `zentui.json`: package configuration
- `package.json`, `package-lock.json`, and `tsconfig.json`: local Pi-package manifest and extension type-check setup
- `npm/package.json` and `npm/package-lock.json`: exact npm Pi-package dependency graph

## Not tracked

- `npm/node_modules/` (recreated with `npm ci --omit=dev`)
- credentials (`~/.pi/agent/auth.json`)
- sessions, model cache, trust decisions, intercom state, and extension logs

Run `./install.sh` from the dotfiles repository to create the required `~/.pi/agent` symlinks and restore missing runtime npm dependencies. For extension development, run `cd pi && npm ci && npm run typecheck`.

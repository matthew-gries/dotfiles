# Pi configuration

This directory is a local [Pi package](https://pi.dev) plus the versioned portion of the global Pi configuration.

## Tracked

- `settings.json`: global Pi preferences and the local package source
- `extensions.txt`: third-party Pi packages installed by `install.sh`
- `extensions/`: local extensions and their non-runtime configuration
- `automode.json` and `zentui.json`: package configuration
- `package.json`, `package-lock.json`, and `tsconfig.json`: local Pi-package manifest and extension type-check setup

## Not tracked

- Pi-managed npm packages under `~/.pi/agent/npm/`
- credentials (`~/.pi/agent/auth.json`)
- sessions, model cache, trust decisions, intercom state, and extension logs

Run `./install.sh` from the dotfiles repository to create the required `~/.pi/agent` symlinks and install the listed Pi extensions. For extension development, run `cd pi && npm ci && npm run typecheck`.

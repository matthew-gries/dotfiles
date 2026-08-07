# Pi configuration

This directory contains only the portable, versioned part of the global Pi configuration:

- `settings.json`: provider-neutral Pi preferences and the third-party package list
- `automode.json`: Auto Mode policy
- `subagent.json`: subagent limits
- `extensions/`: dependency-free local extensions (`.ts` files) that `install.sh` symlinks into `~/.pi/agent/extensions/`

`install.sh` reads `settings.json` and installs every `packages` entry with `pi install`. Pi keeps its downloaded packages and transitive `node_modules` in `~/.pi/agent/npm/`; neither belongs in this repository.

## Machine-specific providers

`settings.json` deliberately does not select a provider or model, and `automode.json` does not pin its classifier model. Pi uses the selected session model for Auto Mode classification. Configure an allowed provider/model on each machine through Pi's normal authentication and model selection flow (or a local, untracked override), without changing this portable configuration.

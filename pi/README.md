# Matt's Pi Setup

Personal Pi resources plus a package list for the third-party Pi extensions I use.

## Install everything on a new machine

```bash
bash ~/dotfiles/pi/install.sh
```

That script installs each package in `packages.txt` with `pi install`, then installs this local package for personal resources/config bootstrapping.

## Install only this local package

```bash
pi install ~/dotfiles/pi
```

This only loads the local resources in this folder. It does **not** install the third-party packages listed in `packages.txt`; use `install.sh` for that.

## Files

- `packages.txt` - third-party Pi packages to install independently
- `extensions/` - custom Pi extensions
- `skills/` - personal skills (`SKILL.md` folders or top-level `.md` files)
- `prompts/` - prompt templates
- `themes/` - custom themes
- `config/pi-permission-system/config.json` - tracked default permission-system config
- `setup/bootstrap-permission-config.ts` - copies the permission-system config into `~/.pi/agent/extensions/pi-permission-system/config.json` if it is missing

Do not store secrets here. Keep API keys and OAuth tokens in `~/.pi/agent/auth.json` or environment variables.

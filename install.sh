#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

create_symlink() {
	local source="$1"
	local target="$2"

	if [ -L "$target" ]; then
		echo "Removing existing symlink: $target"
		rm "$target"
	elif [ -e "$target" ]; then
		echo "Backing up existing file: $target -> ${target}.backup"
		mv "$target" "${target}.backup"
	fi

	mkdir -p "$(dirname "$target")"
	ln -s "$source" "$target"
	echo "Created symlink: $target -> $source"
}

echo "Installing dotfiles from $DOTFILES_DIR"

# nvim config
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# wezterm config
create_symlink "$DOTFILES_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

# Pi configuration. Local extensions are loaded through the local Pi package
# declared in pi/settings.json; npm dependencies remain reproducible via its lockfile.
create_symlink "$DOTFILES_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
create_symlink "$DOTFILES_DIR/pi/npm" "$HOME/.pi/agent/npm"
create_symlink "$DOTFILES_DIR/pi/automode.json" "$HOME/.pi/agent/automode.json"
create_symlink "$DOTFILES_DIR/pi/zentui.json" "$HOME/.pi/agent/zentui.json"

if [ ! -d "$HOME/.pi/agent/npm/node_modules" ]; then
	if command -v npm >/dev/null 2>&1; then
		echo "Installing pinned Pi package dependencies..."
		(cd "$HOME/.pi/agent/npm" && npm ci --omit=dev)
	else
		echo "Warning: npm is required to install Pi package dependencies." >&2
	fi
fi

echo "Done!"

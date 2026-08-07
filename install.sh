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

# Pi configuration. Keep Pi's managed npm directory local; only configuration
# and our dependency-free local extensions are symlinked from this repository.
create_symlink "$DOTFILES_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
create_symlink "$DOTFILES_DIR/pi/automode.json" "$HOME/.pi/agent/automode.json"
create_symlink "$DOTFILES_DIR/pi/subagent.json" "$HOME/.pi/agent/subagent.json"

for extension in "$DOTFILES_DIR"/pi/extensions/*.ts; do
	[ -e "$extension" ] || continue
	create_symlink "$extension" "$HOME/.pi/agent/extensions/$(basename "$extension")"
done

# Remove the old repository symlink so Pi can manage its own package directory.
if [ -L "$HOME/.pi/agent/npm" ]; then
	echo "Removing obsolete Pi npm symlink: $HOME/.pi/agent/npm"
	rm "$HOME/.pi/agent/npm"
fi

if command -v pi >/dev/null 2>&1; then
	echo "Installing Pi extensions..."
	node -e '
		const settings = require(process.argv[1]);
		for (const pkg of settings.packages ?? []) {
			if (typeof pkg === "string") console.log(pkg);
		}
	' "$DOTFILES_DIR/pi/settings.json" | while IFS= read -r package; do
		pi install "$package"
	done
else
	echo "Warning: pi is required to install Pi extensions." >&2
fi

echo "Done!"

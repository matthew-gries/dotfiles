#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

create_symlink() {
	local source="$1"
	local target="$2"
	local backup suffix

	if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
		echo "Already linked: $target"
		return
	fi

	if [ -e "$target" ] || [ -L "$target" ]; then
		backup="${target}.backup"
		suffix=1
		while [ -e "$backup" ] || [ -L "$backup" ]; do
			backup="${target}.backup.${suffix}"
			suffix=$((suffix + 1))
		done
		echo "Backing up existing path: $target -> $backup"
		mv "$target" "$backup"
	fi

	mkdir -p "$(dirname "$target")"
	ln -s "$source" "$target"
	echo "Created symlink: $target -> $source"
}

link_pi_resources() {
	local type="$1"
	local source_dir="$DOTFILES_DIR/pi/$type"
	local source

	[ -d "$source_dir" ] || return 0
	for source in "$source_dir"/*; do
		[ -e "$source" ] || continue
		create_symlink "$source" "$HOME/.pi/agent/$type/$(basename "$source")"
	done
}

echo "Installing dotfiles from $DOTFILES_DIR"

# nvim config
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# wezterm config
create_symlink "$DOTFILES_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

# Pi manages its own settings, credentials, packages, and runtime files.
# If Pi is absent, leave its directory untouched while still installing other dotfiles.
if command -v pi >/dev/null 2>&1; then
	# Migrate only the obsolete repository-owned npm link, not an external npm dir.
	npm_dir="$HOME/.pi/agent/npm"
	if [ -L "$npm_dir" ]; then
		npm_link="$(readlink "$npm_dir")"
		case "$npm_link" in
			"$DOTFILES_DIR"/pi/npm|"$DOTFILES_DIR"/.pi/agent/npm)
				echo "Removing obsolete Pi npm symlink: $npm_dir"
				rm "$npm_dir"
				;;
		esac
	fi

	echo "Installing Pi packages from $DOTFILES_DIR/pi/packages.txt"
	while IFS= read -r package || [ -n "$package" ]; do
		# Ignore blank and comment lines; tolerate whitespace and CRLF in the list.
		package="${package#"${package%%[![:space:]]*}"}"
		package="${package%"${package##*[![:space:]]}"}"
		case "$package" in ''|\#*) continue ;; esac
		echo "Installing Pi package: $package"
		if ! pi install "$package"; then
			echo "Failed to install Pi package: $package" >&2
			exit 1
		fi
	done < "$DOTFILES_DIR/pi/packages.txt"

	for type in extensions prompts skills themes; do
		link_pi_resources "$type"
	done
else
	echo "Warning: pi not found; skipping Pi packages and resource links." >&2
fi

echo "Done!"

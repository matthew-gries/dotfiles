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

echo "Done!"

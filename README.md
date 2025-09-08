# Dotfiles

This repository contains my personal dotfiles for cross-platform development environment.

## Overview

- **Terminal**: WezTerm with tmux-like keybindings
- **Shell**: Zsh with Oh My Zsh and Gruvbox theme
- **Editor**: Neovim with Kickstart configuration

## Prerequisites

### macOS
- macOS (tested on macOS 14+)
- Xcode Command Line Tools
- Homebrew

### Arch Linux
- Arch Linux (or Arch-based distribution)
- `base-devel` group
- `yay` or another AUR helper (recommended)

## Installation

### macOS Setup

#### Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Arch Linux Setup

#### Install AUR Helper (if not already installed)

```bash
# Install yay (recommended AUR helper)
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd .. && rm -rf yay
```

## Platform-Specific Installation

### macOS Installation

#### 1. Install WezTerm

```bash
brew install --cask wezterm
```

**Dependencies for WezTerm:**
- 3270 Nerd Font (install via Homebrew or download from [Nerd Fonts](https://www.nerdfonts.com/))

```bash
brew install font-3270-nerd-font
```

#### 2. Install Zsh and Oh My Zsh

Zsh is included with macOS. Install Oh My Zsh:

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

**Required Dependencies:**

```bash
# Zsh plugins and syntax highlighting
brew install zsh-syntax-highlighting zsh-autosuggestions

# FZF for fuzzy finding
brew install fzf

# Development tools
brew install git python3 node npm yarn

# Display management (for arrange alias)
brew install displayplacer
```

**Additional Development Tools (optional but recommended):**

```bash
# Java development
brew install --cask temurin17

# Maven
brew install maven

# PostgreSQL
brew install postgresql@17

# Google Cloud SDK
brew install --cask google-cloud-sdk

# Python package management
brew install --cask anaconda
```

#### 3. Install Neovim

```bash
brew install neovim
```

**Required Dependencies:**

```bash
# Essential development tools
brew install git make gcc ripgrep fd tree-sitter

# Optional: LazyGit for better Git integration
brew install lazygit
```

### Arch Linux Installation

#### 1. Install WezTerm

```bash
# Install from official repositories
sudo pacman -S wezterm

# Or install from AUR for latest version
yay -S wezterm-git
```

**Dependencies for WezTerm:**

```bash
# Install 3270 Nerd Font
yay -S nerd-fonts-3270
# Or install all nerd fonts (warning: large download)
# yay -S nerd-fonts-complete
```

#### 2. Install Zsh and Oh My Zsh

```bash
# Install Zsh
sudo pacman -S zsh

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set Zsh as default shell
chsh -s $(which zsh)
```

**Required Dependencies:**

```bash
# Zsh plugins and syntax highlighting
sudo pacman -S zsh-syntax-highlighting zsh-autosuggestions

# FZF for fuzzy finding
sudo pacman -S fzf

# Development tools
sudo pacman -S git python nodejs npm yarn

# Base development tools
sudo pacman -S base-devel
```

**Additional Development Tools (optional but recommended):**

```bash
# Java development
sudo pacman -S jdk17-openjdk

# Maven
sudo pacman -S maven

# PostgreSQL
sudo pacman -S postgresql

# Google Cloud SDK
yay -S google-cloud-cli

# Python package management
sudo pacman -S python-pip python-conda
# Or install Anaconda/Miniconda
yay -S miniconda3
```

#### 3. Install Neovim

```bash
# Install Neovim
sudo pacman -S neovim

# Or install latest/nightly version from AUR
yay -S neovim-git
```

**Required Dependencies:**

```bash
# Essential development tools
sudo pacman -S git make gcc ripgrep fd tree-sitter

# Optional: LazyGit for better Git integration
sudo pacman -S lazygit
```

## Configuration (Both Platforms)

**WezTerm Configuration:**
- Copy `.wezterm.lua` to your home directory (`~/.wezterm.lua`)
- The configuration includes:
  - Gruvbox dark theme
  - 3270 Nerd Font at 14pt
  - Leader key: `Ctrl+b` (tmux-style)
  - Split panes: `Leader + -` (vertical), `Leader + \` (horizontal)
  - Navigate panes: `Leader + hjkl`
  - Resize panes: `Leader + r` then `hjkl`
  - New tab: `Leader + c`
  - Close pane: `Leader + x`

**Zsh Configuration:**
- Copy `macos/.zshrc` to your home directory (`~/.zshrc`)
- Install Gruvbox theme for Oh My Zsh:

```bash
git clone https://github.com/sbugzu/gruvbox-zsh.git $ZSH_CUSTOM/themes/gruvbox-zsh
ln -s $ZSH_CUSTOM/themes/gruvbox-zsh/gruvbox.zsh-theme $ZSH_CUSTOM/themes/gruvbox.zsh-theme
```

**Node Version Manager (NVM):**

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

**SDKMAN (Java version management):**

```bash
curl -s "https://get.sdkman.io" | bash
```

**Neovim Configuration:**
1. Create the Neovim config directory:
   ```bash
   mkdir -p ~/.config/nvim
   ```

2. Copy `.config/nvim/init.lua` to `~/.config/nvim/init.lua`

3. Start Neovim - it will automatically:
   - Install the lazy.nvim plugin manager
   - Download and install all plugins
   - Set up language servers via Mason

**Language servers and formatters (automatically managed by Mason):**
- lua-language-server, stylua (Lua)
- pyright, black (Python) 
- typescript-language-server, prettier (JavaScript/TypeScript)
- rust-analyzer, rustfmt (Rust)
- clangd, clang-format (C/C++)
- jdtls (Java)

**Key Features:**
- **Plugin Manager**: lazy.nvim
- **Theme**: Gruvbox
- **Language Support**: LSP for Lua, Python, JavaScript/TypeScript, Rust, C/C++, Java
- **Fuzzy Finding**: Telescope with fzf integration
- **Git Integration**: Gitsigns, LazyGit terminal
- **Autocompletion**: Blink.cmp with snippets
- **Formatting**: Conform.nvim with multiple formatters
- **Terminal**: ToggleTerm for integrated terminal management

**Key Bindings:**
- Leader key: `Space`
- Find files: `<Space>sf`
- Live grep: `<Space>sg`
- Git (LazyGit): `<Space>tg`
- Terminal toggle: `<Space>tt`
- Format buffer: `<Space>f`

## Directory Structure

```
dotfiles/
├── .config/
│   └── nvim/
│       └── init.lua          # Neovim configuration (Kickstart-based)
├── .wezterm.lua              # WezTerm terminal configuration
├── macos/
│   └── .zshrc                # Zsh shell configuration
└── README.md                 # This file
```

## Usage

### Setting up a new machine

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the platform-specific installation steps above (macOS or Arch Linux)

3. Create symlinks (or copy files):
   ```bash
   # WezTerm
   ln -sf ~/.dotfiles/.wezterm.lua ~/.wezterm.lua
   
   # Zsh
   ln -sf ~/.dotfiles/macos/.zshrc ~/.zshrc
   
   # Neovim
   mkdir -p ~/.config/nvim
   ln -sf ~/.dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua
   ```

4. Restart your terminal and enjoy!

## Customization

### WezTerm
- Modify `.wezterm.lua` to change fonts, colors, or keybindings
- The configuration uses tmux-style leader key bindings

### Zsh
- Oh My Zsh plugins are configured in the `plugins=()` array
- Custom aliases and environment variables can be added to `.zshrc`
- The configuration includes paths for various development tools

### Neovim
- The configuration is based on Kickstart.nvim with additional plugins
- Language servers are automatically installed via Mason
- Modify the `servers` table in `init.lua` to add/remove language support
- Formatters are configured in the Conform.nvim section

## Troubleshooting

### Fonts not displaying correctly
- Ensure you have a Nerd Font installed (3270 Nerd Font is configured)
- Check that your terminal is using the correct font

### Zsh plugins not working
- Verify Oh My Zsh is installed correctly
- Check that plugin files exist in the specified paths
- Try restarting your shell session

### Neovim language servers not working
- Run `:checkhealth` in Neovim to diagnose issues
- Use `:Mason` to manually install language servers
- Ensure required build tools are installed (make, gcc, etc.)

### Java development setup
- The configuration expects Java to be installed via SDKMAN
- Update the Java path in `.zshrc` and `init.lua` to match your installation
- Ensure JAVA_HOME is set correctly

### Arch Linux specific issues
- If WezTerm doesn't start, ensure you have the necessary GPU drivers installed
- For font issues, try installing `ttf-liberation` and `noto-fonts` packages
- If zsh plugins don't work, check that the plugin files are sourced correctly in your `.zshrc`
- Some AUR packages may require manual intervention during installation
#!/bin/bash
set -e

# Arch/Omarchy package bootstrap -- the pacman/yay counterpart to brew.sh.
# Run this before install.sh. Needs an AUR helper (Omarchy ships yay) for
# the two packages not in the official repos.

# Dotfile linking
sudo pacman -S --needed stow

# Fonts
sudo pacman -S --needed ttf-jetbrains-mono-nerd

# Terminal (ghostty/config)
sudo pacman -S --needed ghostty

# Window manager: skipped -- AeroSpace is macOS-only. Omarchy's own
# Hyprland config is left alone; see aerospace/ for the macOS setup.

# Shell (zshenv, zprofile)
sudo pacman -S --needed ripgrep fd

# git (gitconfig)
sudo pacman -S --needed git-delta gnupg   # core.pager/interactive.diffFilter, commit.gpgsign/tag.gpgsign

# Neovim (nvim/init.lua) -- Mason installs LSP servers/formatters themselves,
# but needs these runtimes present to do so
sudo pacman -S --needed neovim
sudo pacman -S --needed go            # gopls, golangci-lint, GOPATH tooling
sudo pacman -S --needed nodejs npm    # Mason npm-based LSPs: bashls, dockerls, jsonls, yamlls
yay -S --needed golangci-lint-bin     # not in the official repos
npm install -g markdownlint-cli2      # simpler than chasing an AUR package for a Node CLI

# gitconfig.local (name/email/signingkey) and a GPG signing key are personal
# and not carried by this script -- see gitconfig.local.example and copy your
# key over yourself (`gpg --export-secret-keys ...` / import), same as you
# would for any other machine.

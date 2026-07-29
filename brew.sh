#!/bin/bash
set -e

# Dotfile linking
brew install stow

# Fonts (homebrew/cask-fonts was merged into homebrew/cask, no tap needed)
brew install --cask font-jetbrains-mono-nerd-font

# Terminal (ghostty/config)
brew install --cask ghostty

# Shell (zshenv, zprofile, zsh/locate.zsh)
brew install findutils   # glocate, gupdatedb
brew install ripgrep     # rg: RIPGREP_CONFIG_PATH, nvim grepprg
brew install fd

# git (gitconfig)
brew install git-delta   # core.pager, interactive.diffFilter
brew install gnupg       # commit.gpgsign, tag.gpgsign

# Neovim (nvim/init.lua) -- Mason installs LSP servers/formatters themselves,
# but needs these runtimes present to do so
brew install neovim
brew install go          # gopls, golangci-lint, GOPATH tooling
brew install node        # Mason npm-based LSPs: bashls, dockerls, jsonls, yamlls
brew install golangci-lint      # golangci-lint/golangci.yml
brew install markdownlint-cli2  # markdownlint/markdownlint.yaml

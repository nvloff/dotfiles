#!/bin/bash
set -e

os="$(uname -s)"

# Per-machine zsh overrides -- gitignored, so seed it from the template on
# first run. Never overwrites an existing local.zsh.
[[ -f zsh/.zsh/local.zsh ]] || cp zsh/.zsh/local.zsh.example zsh/.zsh/local.zsh

# AeroSpace is a macOS-only tiling WM -- only stow it there.
packages="zsh git nvim ghostty"
[[ "$os" == Darwin ]] && packages="$packages aerospace"
stow -v $packages

# Claude Code skills: tracked under claude/skills/ (not .claude/, so nothing
# named .claude ends up in git) -- symlink each into place at install time.
# rm the destination first: macOS's `ln -sf` doesn't replace an existing
# symlink that points at a directory -- it follows it and drops the new
# link inside, which on a re-run corrupts the repo with a self-referential
# symlink.
mkdir -p ~/.claude/skills
for skill in claude/skills/*/; do
  skill="${skill%/}"
  target=~/.claude/skills/"$(basename "$skill")"
  rm -f "$target"
  ln -s "$(pwd)/$skill" "$target"
done

#!/bin/bash

set -e

REPO="$PWD"

# Desired symlinks: "repo-relative-path:target-path"
#
# This list is the single source of truth. Delete a line here and the next
# run of this script will remove that symlink too -- on this machine or any
# other -- even if it was created by an older version of this script.
links=(
  "zsh:$HOME/.zsh"
  "zshenv:$HOME/.zshenv"
  "zprofile:$HOME/.zprofile"
  "zshrc:$HOME/.zshrc"
  "gitconfig:$HOME/.gitconfig"
  "gitignore_global:$HOME/.gitignore_global"
  "nvim:$HOME/.config/nvim"
  "ghostty:$HOME/.config/ghostty"
)

is_desired() {
  local target="$1" link
  for link in "${links[@]}"; do
    [[ "${link#*:}" == "$target" ]] && return 0
  done
  return 1
}

# Sweep for symlinks that point into this repo but are no longer desired
# (e.g. dotfiles removed or renamed since the link was created) and remove them.
for dir in "$HOME" "$HOME/.config"; do
  [[ -d "$dir" ]] || continue
  while IFS= read -r -d '' link; do
    target="$(readlink "$link")"
    case "$target" in
      "$REPO"/*)
        is_desired "$link" || { echo "removing orphaned symlink: $link -> $target"; rm -v "$link"; }
        ;;
    esac
  done < <(find "$dir" -maxdepth 1 -type l -print0)
done

# Create/update every desired symlink.
for link in "${links[@]}"; do
  src="${link%%:*}"
  dest="${link#*:}"
  mkdir -p "$(dirname "$dest")"
  ln -vnsf "$REPO/$src" "$dest"
done

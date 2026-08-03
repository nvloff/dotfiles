#!/bin/bash
set -e

stow -v zsh git nvim ghostty

# Claude Code skills: tracked under claude/skills/ (not .claude/, so nothing
# named .claude ends up in git) -- symlink each into place at install time.
mkdir -p ~/.claude/skills
for skill in claude/skills/*/; do
  skill="${skill%/}"
  ln -sf "$(pwd)/$skill" ~/.claude/skills/"$(basename "$skill")"
done

#!/bin/bash
# One-time migration for a machine still on the old bash + flat-symlink setup
# (or a machine that migrated to zsh before the Stow reorg). Safe to re-run --
# only removes symlinks/files that actually exist, then relinks everything
# fresh via install.sh.
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

git pull

stale=(
  ~/.bashrc ~/.bash ~/.bundle.bash ~/.profile
  ~/.zsh ~/.zshenv ~/.zprofile ~/.zshrc
  ~/.gitconfig ~/.gitignore_global
  ~/.config/nvim ~/.config/ghostty
)
for f in "${stale[@]}"; do
  if [ -L "$f" ] || [ -e "$f" ]; then
    rm -v "$f"
  fi
done

bash brew.sh
./install.sh

cat <<'EOF'

Migration done. Left to do manually:
  1. chsh -s /bin/zsh                 (needs your password)
  2. Create per-machine local overrides, if this machine needs them:
       ~/.gitconfig.local             (template: gitconfig.local.example)
       zsh/.zsh/local.zsh             (gitignored, e.g. "source ~/.zsh/macos.zsh")
  3. Fully quit and relaunch Ghostty
EOF

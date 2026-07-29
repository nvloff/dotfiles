# .zprofile - sourced once per login shell, before .zshrc.

if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

typeset -U path

path=(
  "$HOME/go/bin"
  "/usr/local/bin"
  $path
  "$HOME/bin"
)

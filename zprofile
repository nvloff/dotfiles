# .zprofile - sourced once per login shell, before .zshrc.

if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

typeset -U path

path=(
  "$HOME/go/bin"
  "/usr/local/sbin"
  "/usr/local/bin"
  "/opt/homebrew/opt/ruby/bin"
  $path
  "$HOME/local/bin"
  "$HOME/bin"
)

alias g='git'
compdef g=git

# -G is BSD ls's color flag (macOS); GNU ls (Linux) uses --color=auto instead
# -- -G there means something else entirely (drop the group column).
case "$OSTYPE" in
  darwin*) alias ls='ls -G' ;;
  *)       alias ls='ls --color=auto' ;;
esac
alias ll='ls -Alshp'
alias vim='nvim'

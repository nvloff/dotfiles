# .zshrc - sourced for every interactive shell.

# Completion
typeset -U fpath
fpath=("/opt/homebrew/share/zsh/site-functions" $fpath)
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -u
else
  compinit -C -u
fi

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Options
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
unsetopt BEEP

# Keybindings (emacs-style, same as bash default)
bindkey -e

source ~/.zsh/prompt.zsh
source ~/.zsh/aliases.zsh
source ~/.zsh/locate.zsh
source ~/.zsh/local.zsh

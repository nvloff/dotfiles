autoload -Uz vcs_info
setopt PROMPT_SUBST

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats ' (%b%c%u)'
zstyle ':vcs_info:git:*' actionformats ' (%b|%a%c%u)'

precmd() { vcs_info }

PROMPT=$'\n%B%F{blue}%~%f%F{green}${vcs_info_msg_0_}%f%b \n→ '

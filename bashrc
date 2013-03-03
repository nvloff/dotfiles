# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export TERM='xterm-256color'
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"
source ~/.bundle.bash

# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export TERM='xterm-256color'
eval "$(rbenv init -)"
source ~/.bundle.bash

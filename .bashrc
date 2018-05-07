# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if type brew &> /dev/null
then
  if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
    . `brew --prefix`/etc/bash_completion.d/git-completion.bash
  fi

  if [ -f `brew --prefix`/etc/bash_completion.d/git-prompt.sh ]; then
    . `brew --prefix`/etc/bash_completion.d/git-prompt.sh
  fi
else
  source /usr/share/doc/git/contrib/completion/git-completion.bash
  source /usr/share/doc/git/contrib/completion/git-prompt.sh
fi

export TERM='xterm-256color'
source ~/.bundle.bash
eval "$(rbenv init -)"
eval "$(exenv init -)"

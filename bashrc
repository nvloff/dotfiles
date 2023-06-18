# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"

  if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
  fi

  if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
    . `brew --prefix`/etc/bash_completion.d/git-completion.bash
  fi

  if [ -f `brew --prefix`/etc/bash_completion.d/git-prompt.sh ]; then
    . `brew --prefix`/etc/bash_completion.d/git-prompt.sh
  fi
else
  sources=( \
    "/usr/share/doc/git/contrib/completion/git-completion.bash" \
    "/usr/share/doc/git/contrib/completion/git-prompt.sh" \
    "/usr/share/bash-completion/completions/git" \
  )
    for f in "${sources[@]}"
    do
      if [ -f $f ]; then
	source $f
      fi
    done
fi

export TERM='xterm-256color'

source ~/.bash/env.bash
source ~/.bash/local.bash
source ~/.bundle.bash

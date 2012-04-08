source ~/.bash/colors.bash
source ~/.bash/git_ps1.sh

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_DESCRIBE_STYLE="contains"

export PS1="\n\[$EBLUE\]\w\[$EMAGENTA\] "'$(rbenv version-name)'"\[$EGREEN\]"'$(declare -F __git_ps1_local &>/dev/null && __git_ps1_local " (%s)")'"\[$NO_COLOR\] \n→ "


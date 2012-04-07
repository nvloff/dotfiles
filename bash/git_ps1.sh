__git_ps1_local () 
{ 
    local g="$(__gitdir)";
    if [ -n "$g" ]; then
        local r="";
        local b="";
        if [ -f "$g/rebase-merge/interactive" ]; then
            r="|REBASE-i";
            b="$(cat "$g/rebase-merge/head-name")";
        else
            if [ -d "$g/rebase-merge" ]; then
                r="|REBASE-m";
                b="$(cat "$g/rebase-merge/head-name")";
            else
                if [ -d "$g/rebase-apply" ]; then
                    if [ -f "$g/rebase-apply/rebasing" ]; then
                        r="|REBASE";
                    else
                        if [ -f "$g/rebase-apply/applying" ]; then
                            r="|AM";
                        else
                            r="|AM/REBASE";
                        fi;
                    fi;
                else
                    if [ -f "$g/MERGE_HEAD" ]; then
                        r="|MERGING";
                    else
                        if [ -f "$g/CHERRY_PICK_HEAD" ]; then
                            r="|CHERRY-PICKING";
                        else
                            if [ -f "$g/BISECT_LOG" ]; then
                                r="|BISECTING";
                            fi;
                        fi;
                    fi;
                fi;
                b="$(git symbolic-ref HEAD 2>/dev/null)" || { 
                    b="$(
        case "${GIT_PS1_DESCRIBE_STYLE-}" in
        (contains)
          git describe --contains HEAD ;;
        (branch)
          git describe --contains --all HEAD ;;
        (describe)
          git describe HEAD ;;
        (* | default)
          git describe --tags --exact-match HEAD ;;
        esac 2>/dev/null)" || b="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." || b="unknown";
                    b="($b)"
                };
            fi;
        fi;
        local w="";
        local i="";
        local s="";
        local u="";
        local c="";
        local p="";
        if [ "true" = "$(git rev-parse --is-inside-git-dir 2>/dev/null)" ]; then
            if [ "true" = "$(git rev-parse --is-bare-repository 2>/dev/null)" ]; then
                c="BARE:";
            else
                b="GIT_DIR!";
            fi;
        else
            if [ "true" = "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
                if [ -n "${GIT_PS1_SHOWDIRTYSTATE-}" ]; then
                    if [ "$(git config --bool bash.showDirtyState)" != "false" ]; then
                        git diff --no-ext-diff --quiet --exit-code || w="*";
                        if git rev-parse --quiet --verify HEAD > /dev/null; then
                            git diff-index --cached --quiet HEAD -- || i="+";
                        else
                            i="#";
                        fi;
                    fi;
                fi;
                if [ -n "${GIT_PS1_SHOWSTASHSTATE-}" ]; then
                    git rev-parse --verify refs/stash > /dev/null 2>&1 && s="$";
                fi;
                if [ -n "${GIT_PS1_SHOWUNTRACKEDFILES-}" ]; then
                    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                        u="%";
                    fi;
                fi;
                if [ -n "${GIT_PS1_SHOWUPSTREAM-}" ]; then
                    __git_ps1_show_upstream;
                fi;
            fi;
        fi;

        local h="";
        h="$(git rev-parse --short HEAD 2>/dev/null)" 
        local f="$w$i$s$u";
        printf "${1:- (%s)}" "$c${b##refs/heads/}@$h${f:+ $f}$r$p";
    fi
}


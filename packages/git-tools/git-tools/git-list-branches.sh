#!/usr/bin/env sh
git --no-pager branch \
    | fzf-tmux -p --reverse --preview="git --no-pager log --oneline --color=always --graph {-1}" \
        --bind "enter:become(git checkout {-1})" \
        --bind "ctrl-r:become(git rebase -i {-1})" \
        --bind "ctrl-x:become(git branch -d {-1})" \
        --bind "ctrl-s:become(gl {-1})"

#!/usr/bin/env sh
git --no-pager reflog\
    | fzf-tmux -p --no-sort --reverse --preview="git --no-pager show --ext-diff {1}" \
        --bind "enter:execute(git checkout {1})+accept" \
        --bind "ctrl-s:execute(gl {1})+accept" 

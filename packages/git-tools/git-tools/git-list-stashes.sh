#!/usr/bin/env sh
git stash list \
    | fzf-tmux -p --no-sort --reverse --preview "git --no-pager stash show --color=always" \
        --bind "ctrl-s:execute(git stash show {1})" \
        --bind "ctrl-p:become(git stash pop {1})" \
        --bind "ctrl-b:become(git stash branch {1}^)"

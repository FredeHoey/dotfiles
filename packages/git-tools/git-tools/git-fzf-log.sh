#!/usr/bin/env sh
COMMITISH=($@); shift
git --no-pager log --oneline "${COMMITISH[@]}" \
    | fzf-tmux -p -m --no-sort --reverse --preview "git --no-pager show --ext-diff {1}" \
        --bind "ctrl-o:become(git checkout {1})" \
        --bind "ctrl-r:become(git rebase -i {1}^)" \
        --bind "ctrl-a:execute-multi(git cherry-pick {1})+accept" \
        --bind "ctrl-s:become(git show {1})" \
        --bind "enter:become(tmux send-keys {1})"

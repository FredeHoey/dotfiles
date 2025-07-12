#!/usr/bin/env sh
DIR=($1); shift
if [[ ! -z $DIR ]]; then
    PREFIX=$(git rev-parse --show-toplevel)
    DIR=$(echo $PWD | sed -e 's/$PREFIX//')
fi

TARGET=$(git worktree list \
    | grep -v "\[0\]" \
    | fzf-tmux -p -h 90% -w 90% -m --reverse --preview "git show" \
    | cut -f 1 -d ' ')/$DIR
tmux-project $TARGET

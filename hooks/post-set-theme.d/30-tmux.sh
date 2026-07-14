#!/bin/sh

if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
    tmux source-file "$HOME/.config/tmux/tmux.conf"
fi

#!/usr/bin/env bash
for nvim in $(ls /run/user/$(id -u)/nvim.*.0); do
    echo nvim at $nvim > /tmp/stash-tmp
    nvim --server $nvim --remote-expr "execute('colorscheme $STASH_ARG_NAME')"
done

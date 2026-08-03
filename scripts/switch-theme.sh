#!/usr/bin/env bash

busctl --user call org.dotstash.Stash /org/dotstash/Stash org.dotstash.Stash1 ListThemes --json=short \
    | jq -r .data[0][] \
    | fuzzel --dmenu \
    | xargs -I{} busctl --user call org.dotstash.Stash /org/dotstash/Stash org.dotstash.Stash1 SetTheme s "{}"

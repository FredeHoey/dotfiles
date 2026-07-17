#!/usr/bin/env bash

if ! command -v swaymsg >/dev/null 2>&1; then
    exit 0
fi

socket=${SWAYSOCK:-}

if [ -z "$socket" ]; then
    runtime_dir=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
    for candidate in "$runtime_dir"/sway-ipc.*.sock; do
        if [ -S "$candidate" ]; then
            socket=$candidate
            break
        fi
    done
fi

if [ -z "$socket" ] || [ ! -S "$socket" ]; then
    exit 0
fi

SWAYSOCK=$socket swaymsg reload >/dev/null 2>&1 || true

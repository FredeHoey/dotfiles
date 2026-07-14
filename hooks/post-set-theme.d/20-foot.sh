#!/usr/bin/env bash

emit_theme() {
    printf '\033]10;#{{ colors.base05 }}\033\\'
    printf '\033]11;#{{ colors.base00 }}\033\\'

    index=0
    for color in \
        '{{ colors.base00 }}' '{{ colors.base08 }}' '{{ colors.base0B }}' \
        '{{ colors.base0A }}' '{{ colors.base0D }}' '{{ colors.base0E }}' \
        '{{ colors.base0C }}' '{{ colors.base05 }}' '{{ colors.base03 }}' \
        '{{ colors.base08 }}' '{{ colors.base0B }}' '{{ colors.base0A }}' \
        '{{ colors.base0D }}' '{{ colors.base0E }}' '{{ colors.base0C }}' \
        '{{ colors.base07 }}' '{{ colors.base09 }}' '{{ colors.base0F }}' \
        '{{ colors.base01 }}' '{{ colors.base02 }}' '{{ colors.base04 }}' \
        '{{ colors.base06 }}'
    do
        printf '\033]4;%s;#%s\033\\' "$index" "$color"
        index=$((index + 1))
    done
}

server_pid=$(systemctl --user show foot-server.service --value --property MainPID 2>/dev/null)
if [ -z "$server_pid" ] || [ "$server_pid" -eq 0 ] || ! kill -0 "$server_pid" 2>/dev/null; then
    exit 0
fi

# Each foot-server child tree contains the shell (or multiplexer) attached to
# one of foot's PTYs. Walk those trees and update every distinct terminal.
pending=$server_pid
seen=" $server_pid "
terminals=

while [ -n "$pending" ]; do
    pid=${pending%% *}
    pending=${pending#"$pid"}
    pending=${pending# }

    tty=$(readlink "/proc/$pid/fd/0" 2>/dev/null || true)
    case "$tty" in
        /dev/pts/[0-9]*)
            case " $terminals " in
                *" $tty "*) ;;
                *)
                    emit_theme | dd of="$tty" oflag=nonblock status=none 2>/dev/null || true
                    terminals="$terminals $tty"
                    ;;
            esac
            ;;
    esac

    for child in $(pgrep -P "$pid" 2>/dev/null || true); do
        case "$seen" in
            *" $child "*) ;;
            *)
                pending="${pending:+$pending }$child"
                seen="$seen$child "
                ;;
        esac
    done
done

#!/usr/bin/env zsh

switch_to() {
    if [[ -z $TMUX ]]; then
        tmux attach-session -t "$1"
    else
        tmux switch-client -t "$1"
    fi
}

has_session() {
    tmux has-session -t "$1" 2>/dev/null
}

if [[ $# -eq 1 ]]; then
    selected="$1"
else
    selected=$(fzf_dir.sh)
fi

[[ -z "$selected" ]] && exit 0

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s "$selected_name" -c "$selected"
    exit 0
fi

if ! has_session "$selected_name"; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

switch_to "$selected_name"

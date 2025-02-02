#!/usr/bin/env zsh

selected=$1

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(tmux list-sessions 2>/dev/null)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    # Start a new session and attach to it if outside tmux
    tmux new-session -s "$selected_name" -c "$selected"
    exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

# If inside tmux, switch to the selected session, else attach to it
if [[ -n $TMUX ]]; then
    tmux switch-client -t "$selected_name"
else
    tmux attach-session -t "$selected_name"
fi

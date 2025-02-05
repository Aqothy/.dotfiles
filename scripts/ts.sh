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

hydrate() {
    if [ -f "$2/.tmux-sessionizer" ]; then
        tmux send-keys -t "$1" "source $2/.tmux-sessionizer" C-m
    elif [ -f "$HOME/.tmux-sessionizer" ]; then
        tmux send-keys -t "$1" "source $HOME/.tmux-sessionizer" C-m
    fi
}

if [[ $# -eq 1 ]]; then
    selected="$1"
else
    selected=$(
        ( echo "$HOME/.config"
          echo "$HOME/Code"
          fd --type d --max-depth 1 --min-depth 1 . \
            "$HOME/.config" \
            "$HOME/Code" \
            "$HOME/Code/School" \
            "$HOME/Code/Personal" \
            "$HOME/Documents/documents-mac" \
            "$HOME/Documents/documents-mac/school" \
            "$HOME/Documents"
        ) | sed 's:/*$::' | fzf
    )
fi

[[ -z "$selected" ]] && exit 0

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s "$selected_name" -c "$selected"
    hydrate "$selected_name" "$selected"
    exit 0
fi

if ! has_session "$selected_name"; then
    tmux new-session -ds "$selected_name" -c "$selected"
    hydrate "$selected_name" "$selected"
fi

switch_to "$selected_name"

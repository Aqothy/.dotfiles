#!/usr/bin/env zsh

select_dir() {
    (
        echo "$HOME/.config"
        find "$HOME/Code/School" "$HOME/Code/Personal" \
            -maxdepth 1 -type d
    ) | fzf
}

select_dir

#!/usr/bin/env zsh

select_dir() {
    (
        echo "$HOME/.config"
        echo "$HOME/.local/bin"
        echo "$HOME/Downloads"
        find "$HOME/Code/School" "$HOME/Code/Personal" \
            -maxdepth 1 -type d
    ) | fzf
}

select_dir

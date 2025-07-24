#!/usr/bin/env zsh

select_dir() {
    (
        echo "$HOME/.dotfiles"
        echo "$HOME/Code"
        echo "$HOME/.config"
        find "$HOME/Code" "$HOME/Code/School" "$HOME/Code/Personal" \
            "$HOME/Documents/documents-mac" "$HOME/Documents/documents-mac/school" \
            "$HOME/Documents" \
            -mindepth 1 -maxdepth 1 -type d
    ) | fzf
}

select_dir

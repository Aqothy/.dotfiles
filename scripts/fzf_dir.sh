#!/usr/bin/env zsh

select_dir() {
    (
        echo "$HOME/.dotfiles"
        echo "$HOME/Code"
        echo "$HOME/.config"
        fd --type d --hidden --exclude .git --max-depth 1 . \
            "$HOME/Code" \
            "$HOME/Code/School" \
            "$HOME/Code/Personal" \
            "$HOME/Documents/documents-mac" \
            "$HOME/Documents/documents-mac/school" \
            "$HOME/Documents"
    ) | fzf
}

select_dir

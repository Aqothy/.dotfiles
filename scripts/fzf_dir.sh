#!/usr/bin/env zsh

select_dir() {
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
}

select_dir

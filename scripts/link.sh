#!/usr/bin/env zsh
CONFIG_DIR=~/.config
SCRIPT_DIR=~/.local/bin
DOTFILES_DIR=~/.dotfiles

FILES_TO_SYMLINK=(
    aerospace
    bits
    karabiner
    kitty
    lazygit
    nvim
    vscode
    wallpapers
    zed
    zsh
)

SCRIPTS_TO_LINK=(
    fzf_dir.sh
    build_nvim.sh
    link.sh
    npc.sh
)

FILES_TO_SYMLINK_HOME=(
    .zshenv
    .gitconfig
    .gitignore_global
)

create_symlink() {
    local target="$1"
    local link="$2"
    local name="$3"

    if [ -L "$link" ]; then
        # It's already a symlink, check if it points to the right target
        current_target=$(readlink "$link")
        if [ "$current_target" = "$target" ]; then
            echo "Skipping $link: correct symlink already exists."
        else
            echo "Updating symlink for $name (was pointing to $current_target)"
            rm "$link"
            ln -s "$target" "$link"
            echo "Updated symlink for $name"
        fi
    elif [ -e "$link" ]; then
        echo "Warning: $link exists but is not a symlink. Skipping."
    else
        ln -s "$target" "$link"
        echo "Created symlink for $name"
    fi
}

for file in "${FILES_TO_SYMLINK[@]}"; do
    target="$DOTFILES_DIR/$file"
    link="$CONFIG_DIR/$file"
    create_symlink "$target" "$link" "$file"
done

for script in "${SCRIPTS_TO_LINK[@]}"; do
    target="$DOTFILES_DIR/scripts/$script"
    link="$SCRIPT_DIR/${script%.sh}"

    if [ ! -x "$target" ]; then
        echo "Making $target executable..."
        chmod +x "$target"
    fi

    create_symlink "$target" "$link" "${script%.sh}"
done

for file in "${FILES_TO_SYMLINK_HOME[@]}"; do
    target="$DOTFILES_DIR/$file"
    link="$HOME/$file"
    create_symlink "$target" "$link" "$file"
done

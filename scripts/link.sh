#!/usr/bin/env zsh

# Directory containing your dotfiles
DOTFILES_DIR=~/.config
SCRIPT_DIR=/usr/local/bin

# List of files/folders to symlink
FILES_TO_SYMLINK=(
  .zshrc
  .gitconfig
)

SCRIPTS_TO_LINK=(
    link.sh
    nvupdate.sh
)

# Loop through files and create symlinks
for file in "${FILES_TO_SYMLINK[@]}"; do
  target="$DOTFILES_DIR/$file"
  link="$HOME/$file"

  if [ -e "$link" ]; then
    echo "Skipping $link: already exists."
  else
    ln -s "$target" "$link"
    echo "Created symlink for $file"
  fi
done

# Loop through scripts and create symlinks
for script in "${SCRIPTS_TO_LINK[@]}"; do
    target="$DOTFILES_DIR/scripts/$script"
    link="$SCRIPT_DIR/$script"

    if [ -e "$link" ]; then
        echo "Skipping $link: already exists."
    else
        sudo ln -s "$target" "$link"
        echo "Created symlink for $script"
    fi
done


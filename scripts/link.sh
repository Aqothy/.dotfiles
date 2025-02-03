#!/usr/bin/env zsh

# Directory containing your dotfiles
DOTFILES_DIR=~/.config
SCRIPT_DIR=~/.local/bin

# List of files/folders to symlink
# Gotta do lazygit config manually
FILES_TO_SYMLINK=(
  .zshrc
  .gitconfig
  .ignore
  .zshenv
  .zprofile
)

SCRIPTS_TO_LINK=(
    ts.sh
    fzf_dir.sh
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
    link="$SCRIPT_DIR/${script%.sh}"  # Remove .sh extension from the link

    # Ensure the script is executable before linking
    if [ ! -x "$target" ]; then
        echo "Making $target executable..."
        chmod +x "$target"
    fi

    if [ -e "$link" ]; then
        echo "Skipping $link: already exists."
    else
        ln -s "$target" "$link"
        echo "Created symlink for ${script%.sh}"
    fi
done

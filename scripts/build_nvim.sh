#!/usr/bin/env zsh

function build_nvim() {
    local NVIM_DIR="$HOME/Code/Personal/neovim"
    local BRANCH="master"
    local INSTALL_DIR="$HOME/.nvim"

    # Check if nvim directory exists
    if [ ! -d "$NVIM_DIR" ]; then
        echo "No nvim directory found. Please check the path."
        return 1
    fi

    cd "$NVIM_DIR" || { echo "Error: Failed to change directory to '$NVIM_DIR'"; return 1; }

    git checkout "$BRANCH"
    git pull

    if [ -d "$INSTALL_DIR" ]; then
        echo "Cleaning out previous builds..."
        rm -rf "$INSTALL_DIR"
    else
        echo "No previous builds found."
    fi

    make distclean
    make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$INSTALL_DIR" install
}

build_nvim

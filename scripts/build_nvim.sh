#!/usr/bin/env zsh
function build_nvim(){
    # Prompt user for nvim path, default to /Volumes/x/neovim
    read "NVIM_DIR?Enter your nvim directory path: "
    NVIM_DIR=${NVIM_DIR:-/Volumes/x/neovim}
    
    # Check if there is nvim directory and already connected to ssd
    if [ ! -d "$NVIM_DIR" ]; then
        echo "No nvim directory found. Please check the path."
        return 1
    fi
    if ! cd "$NVIM_DIR"; then
        echo "Error: Failed to change directory to '$NVIM_DIR'"
        return 1
    fi
    
    # Check if there is a .git directory
    if [ ! -d ".git" ]; then
        echo "No .git directory found. Please check the path."
        return 1
    fi
    
    git switch master
    git pull
    
    # Clean out previous builds
    INSTALL_DIR="/usr/local/share/nvim"
    if [ -d "$INSTALL_DIR" ]; then
        echo "Cleaning out previous builds..."
        rm -rf "$INSTALL_DIR"
    else
        echo "No previous builds found."
    fi
    
    make distclean
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    make install
}
build_nvim

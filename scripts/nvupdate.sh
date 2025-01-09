#!/usr/bin/env zsh

# Path to Neovim source directory
NVIM_SRC="/Volumes/x/neovim"

cd $NVIM_SRC || exit
git pull
make CMAKE_BUILD_TYPE=Release
sudo make install
nvim --version

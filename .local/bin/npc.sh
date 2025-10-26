#!/usr/bin/env zsh

# Use vscode electron as node for node pointer compression to reduce memory usage
ELECTRON="/Applications/Visual Studio Code.app/Contents/MacOS/Electron"
ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$@"

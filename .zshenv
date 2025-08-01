# XDG base directories.
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER='nvim +Man!'

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export FZF_DEFAULT_OPTS="--layout=reverse"

export SHELL_SESSIONS_DISABLE=1

export GOBIN=$HOME/go/bin

export PATH=$PATH:$GOBIN
export PATH=$PATH:/usr/local/lua-5.4.7/src
export PATH=$PATH:/usr/local/texlive/2024basic/bin/universal-darwin
export PATH="$HOME/.local/bin:$PATH" # Local scripts
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# TODO: Delete this in the future
export ANDROID_HOME="$HOME/.android_sdk"
export ANDROID_SDK_ROOT="$HOME/.android_sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$ANDROID_SDK_ROOT/emulator:$PATH"
export PATH=$PATH:/usr/local/google-cloud-sdk/bin

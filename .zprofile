eval "$(/opt/homebrew/bin/brew shellenv)"

# XDG base directories.
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export GOBIN=$HOME/go/bin
export PATH=$PATH:$GOBIN
export PATH=$PATH:/usr/local/lua-5.4.7/src
export PATH=$PATH:/usr/local/texlive/2024basic/bin/universal-darwin
export PATH=$PATH:/usr/local/google-cloud-sdk/bin
export PATH="$HOME/.local/bin:$PATH" # Local scripts
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

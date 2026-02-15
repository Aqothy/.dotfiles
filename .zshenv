export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export PATH="$HOME/.local/bin:$PATH" # Local scripts
export PATH="$HOME/.nvim/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

[[ -f "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"

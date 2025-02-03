eval "$(/opt/homebrew/bin/brew shellenv)"

# XDG base directories.
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR="$(which nvim)"
export VISUAL="$EDITOR"

export GOBIN=$HOME/go/bin
export PATH=$PATH:$GOBIN
export PATH=$PATH:/usr/local/nvim-nightly/bin
export PATH=$PATH:/usr/local/lua-5.4.7/src
export PATH=$PATH:/usr/local/texlive/2024basic/bin/universal-darwin
export PATH=$PATH:/usr/local/google-cloud-sdk/bin
export PATH="$HOME/.local/bin:$PATH" # Local scripts
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/aqothy/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/aqothy/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/aqothy/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/aqothy/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/Users/aqothy/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "/Users/aqothy/miniforge3/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

export DOTNET_CLI_TELEMETRY_OPTOUT=1

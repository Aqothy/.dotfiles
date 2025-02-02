export ZSH="$HOME/.oh-my-zsh"

# TODO: Need to modify command prompt
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# syntax highlighting not that helpful tbh
plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

alias zshc="nvim ~/.zshrc"

alias icat="kitten icat"

alias cm="chmod +x"

alias py="python3"

alias tm="tmux"

alias clang="clang++ -std=c++20"

alias so="source ~/.zshrc"

alias lg="lazygit"

[[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh"

### this will break in since some of the packages will be installed using homebrew
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# TODO: Might need to change paths in the future
export GOBIN=$HOME/go/bin

export PATH=$PATH:$GOBIN

export EDITOR="nvim"

export VISUAL="nvim"

export PATH=$PATH:/usr/local/nvim-nightly/bin

export PATH=$PATH:/usr/local/lua-5.4.7/src

export PATH=$PATH:/usr/local/texlive/2024basic/bin/universal-darwin

export PATH=$PATH:/usr/local/google-cloud-sdk/bin

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

###

# search in projects
fzf_append_dir_widget() {
    local dir
    dir=$(fzf_dir.sh) || return
    if [[ -n "$dir" ]]; then
        LBUFFER+="$dir" # add the selected directory to the command line
        zle redisplay # refresh the command line
    fi
}

zle -N fzf_append_dir_widget
bindkey '^F' fzf_append_dir_widget

export FZF_DEFAULT_COMMAND='fd --type f --exclude .git'

source <(fzf --zsh)

export DOTNET_CLI_TELEMETRY_OPTOUT=1

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias zshc="nvim ~/.zshrc"

alias py="python3"

alias nv="nvim"

alias clang="clang++ -std=c++20"

alias so="source ~/.zshrc"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
 
export PATH=/Library/PostgreSQL/16/bin:$PATH

export GOBIN=$HOME/go/bin

export PATH=$PATH:$GOBIN

export PATH=$PATH:/usr/local/nvim-macos-arm64/bin

export PATH=$PATH:/usr/local/lua-5.4.7/src

export PATH=$PATH:/usr/local/texlive/2024basic/bin/universal-darwin

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

# Bind Ctrl+F to run the fzf_cd.sh script
bindkey -s '^F' 'source fzf_cd.sh\n'

export FZF_DEFAULT_COMMAND='rg --files --glob "!**/.git/*" --glob "!Pictures/*" --glob "!Movies/*" --glob "!Music/*" --glob "!go/*" --glob "!miniforge3/*" --glob "!Library/*" --glob "!Applications/*"'

nfz() {
    local file
    file=$(fzf)
    [ -n "$file" ] && nvim "$file"
}

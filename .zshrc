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

#alias nv="nvim"

alias clang="clang++ -std=c++20"

alias so="source ~/.zshrc"

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

export PATH=$PATH:/usr/local/nvim-macos-arm64/bin

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

select_dir() {
    (echo ~/.config; echo ~/Code; fd --type d --max-depth 1 --min-depth 1 . ~/.config ~/Code ~/Code/School ~/Code/Personal ~/Documents/documents-mac ~/Documents/documents-mac/school ~/Documents) | fzf
}

# search in projects
fzf_append_dir_widget() {
    local dir
    dir=$(select_dir) || return # Call the function and store the result
    if [[ -n $dir ]]; then
        LBUFFER+="$dir" # Append the selected directory to the current command
        zle redisplay   # Refresh the prompt to show the updated command
    fi
}

zle -N fzf_append_dir_widget

bindkey '^F' fzf_append_dir_widget

# Define FZF_DEFAULT_COMMAND for searching in the home directory
# export FZF_DEFAULT_COMMAND='cd ~ && rg --files --glob "!**/.git/*" --glob "!Pictures/*" --glob "!Movies/*" --glob "!Music/*" --glob "!go/*" --glob "!miniforge3/*" --glob "!Library/*" --glob "!Applications/*" | sed "s|^|$HOME/|"'
# need to include . to return all results
export FZF_DEFAULT_COMMAND='fd --type f --exclude .git --exclude Pictures --exclude Movies --exclude Music --exclude go --exclude miniforge3 --exclude Library --exclude Applications . ~'

# Ensure Ctrl-T uses the same default command
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Define FZF_CHILD_COMMAND for searching in the current directory
export FZF_CHILD_COMMAND='fd --type f --exclude .git'

export FZF_DEFAULT_OPTS="--layout=reverse"

# Bind Ctrl-H to use FZF in the current (child) directory
fzf_child_widget() {
    local selected
    selected=$(eval "$FZF_CHILD_COMMAND" | fzf) || return
    LBUFFER+="$selected" # Append the selected file/directory to the current command
    zle redisplay
}

zle -N fzf_child_widget

bindkey '^S' fzf_child_widget

source <(fzf --zsh)

export DOTNET_CLI_TELEMETRY_OPTOUT=1

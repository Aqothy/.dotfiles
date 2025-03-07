setopt auto_cd  # Auto-cd if command is a directory
unsetopt CASE_GLOB  # Case-insensitive filename matching
unsetopt CASE_MATCH  # Case-insensitive case statements
zstyle ':completion:*' menu select

# Aliases
alias icat="kitten icat"
alias cm="chmod +x"
alias py="python3"
alias tm="tmux"
alias lg="lazygit"
alias clang="clang++ -std=c++20"
[[ "$TERM" == "xterm-kitty" ]] && alias ssh='TERM=xterm-256color command ssh'

export EDITOR="nvim"
export VISUAL="nvim"
export FZF_DEFAULT_OPTS="--layout=reverse"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Keybindings and Zsh Widgets
fzf_append_dir_widget() {
    local dir
    dir=$(fzf_dir.sh) || return
    if [[ -n "$dir" ]]; then
        LBUFFER+="$dir"
    fi
}
zle -N fzf_append_dir_widget
bindkey '^f' fzf_append_dir_widget
bindkey -s '^h' 'ts\n'

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/aqothy/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/aqothy/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/aqothy/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/aqothy/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

source <(fzf --zsh)
eval "$(starship init zsh)"

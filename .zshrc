# Auto-cd if the command is a directory and can't be executed as a normal command.
setopt auto_cd

# Case-insensitive filename matching
unsetopt CASE_GLOB

# Case-insensitive case statements
unsetopt CASE_MATCH

# Case-insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Aliases
alias icat="kitten icat"
alias cm="chmod +x"
alias py="python3"
alias tm="tmux"
alias lg="lazygit"
alias clang="clang++ -std=c++20"
[[ "$TERM" == "xterm-kitty" ]] && alias ssh='TERM=xterm-256color command ssh'

# search in projects
fzf_append_dir_widget() {
    local dir
    dir=$(fzf_dir.sh) || return
    if [[ -n "$dir" ]]; then
        LBUFFER+="$dir" # add the selected directory to the command line
    fi
}

zle -N fzf_append_dir_widget
bindkey '^f' fzf_append_dir_widget

bindkey -s '^k' 'ts\n'

export FZF_DEFAULT_OPTS="--layout=reverse"
export FZF_DEFAULT_COMMAND='fd --type f --exclude .git'

source <(fzf --zsh)

eval "$(starship init zsh)"

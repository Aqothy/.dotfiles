export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
KEYTIMEOUT=1

plugins=(git vi-mode zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Aliases
alias icat="kitten icat"
alias cm="chmod +x"
alias py="python3"
alias lg="lazygit"
alias cpp="clang++ -std=c++20"
alias nv="nvim"
alias g="git"
alias gg="git status"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gb="git branch"
alias gac="git add -A && git commit"
alias gs="git switch"
alias gd="git diff"
alias co="git checkout"
alias pu="git push"
alias pl="git pull"
alias fe="git fetch"
alias re="git rebase"
alias gl="git log"
alias gt="git log --graph --oneline --decorate --all"
alias so="source ~/.zshrc"
alias sb="git branch --no-color --sort=-committerdate --format='%(refname:short)' | fzf --header 'git switch' | xargs git switch"

[[ "$TERM" == "xterm-ghostty" ]] && alias ssh='TERM=xterm-256color command ssh'

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR="vim"
    export VISUAL="vim"
else
    export EDITOR="nvim"
    export VISUAL="nvim"
fi

export FZF_DEFAULT_OPTS="--layout=reverse"
export FZF_DEFAULT_COMMAND='fd --type f --type l --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
--preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}'
--bind 'ctrl-b:preview-page-up,ctrl-f:preview-page-down'"
export FZF_CTRL_R_OPTS="
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)'
--color header:italic
--header 'Press CTRL-Y to copy command into clipboard'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

export MANPAGER='nvim +Man!'

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Keybindings and Zsh Widgets
fzf_append_dir_widget() {
    local dir
    dir=$(fzf_dir.sh) || return
    if [[ -n "$dir" ]]; then
        LBUFFER+="\"$dir\""
    fi
}
zle -N fzf_append_dir_widget

bindkey '^f' fzf_append_dir_widget

bindkey -M vicmd '^v' edit-command-line

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

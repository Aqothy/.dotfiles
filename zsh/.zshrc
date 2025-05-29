# ref:
# https://thevaluable.dev/zsh-completion-guide-examples/
# https://thevaluable.dev/zsh-install-configure-mouseless/

# Navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

autoload -Uz colors && colors

# Aliases
alias icat="kitten icat"
alias cm="chmod +x"
alias py="python3"
alias lg="lazygit"
alias cpp="clang++ -std=c++20"
alias vi="nvim"
alias svi="nvim --listen /tmp/nvim"
alias g="git"
alias gs="git status"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gm="git merge"
alias gb="git branch"
alias gac="git add -A && git commit"
alias sb="git switch"
alias sc="git switch -c"
alias st="git stash"
alias gd="git diff"
alias co="git checkout"
alias pu="git push"
alias pl="git pull"
alias fe="git fetch"
alias rb="git rebase"
alias gl="git log"
alias gt="git log --graph --oneline --decorate --all"
alias so="source ${ZDOTDIR}/.zshrc"
alias ls='ls --color=auto'
alias rg='rg --color=auto'
alias ...='cd ../..'
alias ....='cd ../../..'
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

mkcd() {
  mkdir -p "$1" && cd "$1"
}

[[ "$TERM" == "xterm-kitty" ]] && alias ssh='TERM=xterm-256color ssh'

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="vim"
  export VISUAL="vim"
else
  export EDITOR="nvim"
  export VISUAL="nvim"
fi

# Prompt
setopt PROMPT_SUBST

# Git prompt functions
function git_prompt_info() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    return
  fi

  local branch
  local dirty=""

  # Get branch name
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

  # Check for any changes (staged, unstaged, or untracked)
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    dirty=" %F{red}✘%f"
  fi

  echo " %F{yellow} %f%F{blue}${branch}%f${dirty}"
}

# Set prompt
PROMPT='%B%(?:%F{green}➜%f:%F{red}!%f) %F{cyan}%c%f$(git_prompt_info)%b '

# vi mode stuff
bindkey -v
export KEYTIMEOUT=1

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^V' edit-command-line

# Add Vi text-objects for brackets and quotes
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
  bindkey -M $km -- '-' vi-up-line-or-history
  for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
    bindkey -M $km $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $km $c select-bracketed
  done
done

# Emulation of vim-surround
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd cs change-surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd gz add-surround
bindkey -M visual gz add-surround

# Completion
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

_comp_options+=(globdots)

setopt GLOB_DOTS
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt CORRECT

zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(uv generate-shell-completion zsh)"

export FZF_DEFAULT_OPTS="--layout=reverse --color=bg+:#d5c4a1,bg:#f2e5bc,spinner:#9d0006,hl:#928374,fg:#3c3836,header:#928374,info:#427b58,pointer:#9d0006,marker:#9d0006,fg+:#3c3836,prompt:#9d0006,hl+:#9d0006"
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

source <(fzf --zsh)

fzf_append_dir_widget() {
  local dir
  dir=$(fzf_dir) || return
  if [[ -n "$dir" ]]; then
    LBUFFER+="\"$dir\""
  fi
}
zle -N fzf_append_dir_widget

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    git)          git --help -a | grep -E '^\s+' | awk '{print $1}' | fzf "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    *)            fzf "$@" ;;
  esac
}

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Keybinds
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '^[[3~' delete-char
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey "^U" backward-kill-line
bindkey '^f' fzf_append_dir_widget

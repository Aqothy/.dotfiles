# ref:
# https://thevaluable.dev/zsh-completion-guide-examples/
# https://thevaluable.dev/zsh-install-configure-mouseless/

bindkey -e

# Zsh Options
setopt AUTO_CD
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt PROMPT_SUBST
setopt GLOB_DOTS
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt CORRECT
setopt GLOB_COMPLETE

autoload -Uz colors && colors

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias py="python3"
alias gg="lazygit"
alias cpp="clang++ -std=c++20"
alias vi="nvim"
alias svi="nvim --listen /tmp/nvim"
alias gaa="git add -A"
alias sb="git switch"
alias sc="git switch -c"
alias gd="git difftool --dir-diff"
alias so="source $ZDOTDIR/.zshrc"
alias md='mkdir -p'

export MANPAGER='nvim +Man!'

export FZF_DEFAULT_OPTS="--layout=reverse"
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

typeset -g __git_async_fd
typeset -g _git_status_prompt=""

__async_git_start() {
  # Close previous file descriptor
  if [[ -n "$__git_async_fd" ]] && { true <&$__git_async_fd } 2>/dev/null; then
    exec {__git_async_fd}<&-
    zle -F $__git_async_fd
  fi

  # Fork process to fetch git status
  exec {__git_async_fd}< <(__async_git_info $PWD)

  # Call __async_git_done when data is ready
  zle -F "$__git_async_fd" __async_git_done
}

__async_git_info() {
  cd -q "$1"
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch
  local dirty=""

  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return

  if ! git diff --quiet --no-ext-diff 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    dirty=" %F{red}✘%f"
  fi

  echo " %F{yellow}%f %F{blue}${branch}%f${dirty}"
}

__async_git_done() {
  # Read git status from file descriptor
  _git_status_prompt="$(<&$1)"
  # Remove handler and close file descriptor
  zle -F "$1"
  exec {1}<&-
  zle && zle reset-prompt
}

prompt_precmd() {
  __async_git_start
}

prompt_chpwd() {
  _git_status_prompt=""
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_precmd
add-zsh-hook chpwd prompt_chpwd

PROMPT='%B%(?:%F{green}➜%f:%F{red}!%f) %F{cyan}%~%f${_git_status_prompt}%b '

autoload -Uz compinit && compinit

zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

zstyle ':completion:*' menu select
# Exact -> Case Insensitive -> Substring
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(uv generate-shell-completion zsh)"

source <(fzf --zsh)

fzf_append_dir_widget() {
  local dir
  dir=$(fzf_dir) || return
  if [[ -n "$dir" ]]; then
    LBUFFER+="\"$dir\""
  fi
}
zle -N fzf_append_dir_widget

bindkey '^f' fzf_append_dir_widget

[ -f "/Users/aqothy/.ghcup/env" ] && . "/Users/aqothy/.ghcup/env" # ghcup-env

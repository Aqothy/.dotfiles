# ref:
# https://thevaluable.dev/zsh-completion-guide-examples/
# https://thevaluable.dev/zsh-install-configure-mouseless/

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
alias g="lazygit"
alias cpp="clang++ -std=c++20"
alias vi="nvim"
alias svi="nvim --listen /tmp/nvim"
alias gaa="git add -A"
alias sb="git switch"
alias sc="git switch -c"
alias so="source $ZDOTDIR/.zshrc"

function git_prompt_info() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    return
  fi

  local branch
  local dirty=""

  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

  if [[ -n $(git status --porcelain 2>/dev/null | head -n1) ]]; then
    dirty=" %F{red}✘%f"
  fi

  echo " %F{yellow}%f %F{blue}${branch}%f${dirty}"
}

PROMPT='%B%(?:%F{green}➜%f:%F{red}!%f) %F{cyan}%c%f$(git_prompt_info)%b '

autoload -Uz compinit && compinit

zstyle ':completion:*' menu select
# Exact -> Case Insensitive -> Substring
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

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

# ref:
# https://thevaluable.dev/zsh-completion-guide-examples/
# https://thevaluable.dev/zsh-install-configure-mouseless/

bindkey -e

# Zsh Options
HISTSIZE=10000
SAVEHIST=10000
setopt AUTO_CD
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt PROMPT_SUBST
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt CORRECT
setopt GLOB_COMPLETE
setopt GLOB_DOTS
setopt HIST_VERIFY

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias py="python3"
alias cpp="clang++ -std=c++20"
alias vi="nvim"
alias svi="nvim --listen /tmp/nvim"
alias gs="git status -s"
alias gaa="git add -A"
alias sc="git switch -c"
alias ds='DELTA_FEATURES=+side-by-side git diff'
alias lg="lazygit"
alias ld='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias so="source $ZDOTDIR/.zshrc"
alias md='mkdir -p'
alias ls='ls -G -l'

d() {
   git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

sb() {
  if [[ -n "$1" ]]; then
      git switch $1
      return
  fi
  local branches branch
  branches=$(git --no-pager branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git switch $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

co() {
  if [[ -n "$1" ]]; then
      git checkout $1
      return
  fi
  local commits commit
  commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}

export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER='nvim +Man!'

export FZF_DEFAULT_OPTS="--layout=reverse"
export FZF_DEFAULT_COMMAND='rg --files --no-messages --color=never -g "!.git" -g "!.DS_Store" --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

_git_status_prompt() {
  local b

  b=$(git symbolic-ref --quiet --short HEAD 2>/dev/null \
     || git rev-parse --short HEAD 2>/dev/null) || return

  echo " %F{yellow}%f %F{blue}${b}%f"
}

PROMPT='%B%(?:%F{green}➜%f:%F{red}!%f) %F{cyan}%~%f$(_git_status_prompt)%b '

zstyle ':completion:*' use-cache yes
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
# Case Insensitive -> Substring
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

autoload -Uz compinit && compinit
compdef _git sb=git-switch
compdef _git co=git-checkout

eval "$(mise activate zsh)"
eval "$(uv generate-shell-completion zsh)"

source <(fzf --zsh)

fzf_append_dir_widget() {
  local dir
  dir=$(fzf_dir.sh) || return
  if [[ -n "$dir" ]]; then
    LBUFFER+="\"$dir\""
  fi
}
zle -N fzf_append_dir_widget

bindkey '^f' fzf_append_dir_widget

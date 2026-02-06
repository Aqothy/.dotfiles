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
setopt HIST_VERIFY

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias py="python3"
alias lg="lazygit"
alias cpp="clang++ -std=c++20"
alias vi="nvim"
alias svi="nvim --listen /tmp/nvim"
alias gaa="git add -A"
alias sc="git switch -c"
alias gd="git difftool --dir-diff"
alias so="source $ZDOTDIR/.zshrc"
alias md='mkdir -p'
alias ld='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
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

autoload -Uz vcs_info

typeset -g __git_async_fd=""
typeset -g _git_status_prompt=""

# VCS styling
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{yellow}%f %F{blue}%b%f%c%u'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}%f %F{blue}%b%f %F{red}[%a]%f%c%u'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr ' %F{green}%f'
zstyle ':vcs_info:*' unstagedstr ' %F{red}✘%f'

__async_git_info() {
  emulate -L zsh
  cd -q "$1" || return
  vcs_info
  [[ -n ${vcs_info_msg_0_} ]] || return
  echo "${vcs_info_msg_0_}"
}

# Called when new data is ready to be read from the pipe
__async_git_done() {
  local fd=$1
  local new_prompt

  # Read everything from the fd
  new_prompt="$(<&$fd)"
  if [[ "$_git_status_prompt" != "$new_prompt" ]]; then
    _git_status_prompt="$new_prompt"
    zle reset-prompt
  fi
  # remove the handler and close the file descriptor
  zle -F "$fd"
  exec {fd}<&-
  __git_async_fd=""
}

__async_git_start() {
  # remove any existing handler and close the previous fd
  if [[ -n "$__git_async_fd" ]] && { true <&$__git_async_fd } 2>/dev/null; then
    zle -F "$__git_async_fd"
    exec {__git_async_fd}<&-
    __git_async_fd=""
  fi
  # fork a process to fetch the vcs status and open a pipe to read from it
  exec {__git_async_fd}< <(__async_git_info "$PWD")

  # When the fd is readable, call the response handler
  zle -F "$__git_async_fd" __async_git_done
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_precmd
add-zsh-hook chpwd prompt_chpwd

prompt_precmd() {
  __async_git_start # start async job to populate git info
}

prompt_chpwd() {
  _git_status_prompt="" # clear current vcs_info
}

PROMPT='%B%(?:%F{green}➜%f:%F{red}!%f) %F{cyan}%~%f${_git_status_prompt}%b '

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

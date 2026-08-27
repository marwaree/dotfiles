# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="lukerandall"

ZSH_DISABLE_COMPFIX="true"

# ENABLE_CORRECTION="true"

plugins=(
	git 
	zsh-autosuggestions
	zsh-syntax-highlighting
	sudo
)
# Plugin Edit
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'


source $ZSH/oh-my-zsh.sh

# Aliases

alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd="zd"
alias vim="nvim"
alias cat="bat --theme-dark ansi"
alias rm='rmtrash'
alias rmdir='rmdirtrash'

# Directories
alias -g '...'='../..'
alias -g '....'='../../..'

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }


fastfetch

# Keep at the end of the file
eval "$(zoxide init zsh)"
export PATH="$HOME/.local/bin:$PATH"

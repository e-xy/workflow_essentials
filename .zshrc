# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ███████╗███╗░░██╗██████╗░██╗░░░██╗░██████╗████████╗██████╗░██╗███████╗░██████╗
# ██╔════╝████╗░██║██╔══██╗██║░░░██║██╔════╝╚══██╔══╝██╔══██╗██║██╔════╝██╔════╝
# █████╗░░██╔██╗██║██║░░██║██║░░░██║╚█████╗░░░░██║░░░██████╔╝██║█████╗░░╚█████╗░
# ██╔══╝░░██║╚████║██║░░██║██║░░░██║░╚═══██╗░░░██║░░░██╔══██╗██║██╔══╝░░░╚═══██╗
# ███████╗██║░╚███║██████╔╝╚██████╔╝██████╔╝░░░██║░░░██║░░██║██║███████╗██████╔╝
# ╚══════╝╚═╝░░╚══╝╚═════╝░░╚═════╝░╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═╝╚══════╝╚═════╝░
#
# ENDUSTRIES | by e-xy ;D | .zshrc configures your zsh setup, aliases, and PATH
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# start fastfetch
fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# source your files (CHANGE THIS TO YOUR LIKING)
source /usr/share/cachyos-zsh-config/cachyos-config.zsh
source ~/.secrets

# Helpful aliases
alias c='clear' # clear terminal
alias l='eza -lh --icons=auto' # long list
alias ls='eza -1 --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias vc='code' # gui code editor
alias editpac='sudo vim /etc/pacman.conf'

# funny aliases
jclr() {
  find . -name "*.class" -type f -delete
}
# jcr() {
#   javac "$1" && java "${1%.java}"
# }
jcr() {
  local file
  file=$(fd -t f -e java | fzf) && javac "$file" && java "${file%.java}"
}
jcrf() {
  local file
  file=$(fzf) || return
  jcr "$file"
}
vf() {
  local file
  file=$(fzf) && nvim "$file"
}

# -------- C --------
ccr() {
  local file
  file=$(fd -t f -e c | fzf) && gcc "$file" -o "${file%.*}.o" && "./${file%.*}.o"
}

cclr() {
  find . \( -name "*.o" -o -name "a.out" \) -type f -delete
}

# -------- C++ --------
cppr() {
  local file
  file=$(fd -t f -e cpp -e cc -e cxx | fzf) && g++ "$file" -o "${file%.*}.o" && "./${file%.*}.o"
}

cpplr() {
  find . \( -name "*.o" -o -name "a.out" \) -type f -delete
}

alias plz="sudo"
alias fucking="sudo"
alias lss="ls | xargs du -sh"
alias lssf="ls | xargs du -sh | rg"
alias rlss="du -ah . | sort -hr | head -n 10"

# my dumbass "gush" github script (I'm lazy)
alias gush="~/.config/help_scripts/gush.sh"

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="$PATH:$HOME/.local/bin"
eval "$(zoxide init zsh)"

# setup pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

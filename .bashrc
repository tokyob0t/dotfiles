#
# ~/.bashrc
#

[[ $- != *i* ]] && return

if [[ -f "$HOME/.profile" ]]; then
    source "$HOME/.profile"
fi

# PS1='[\u@\h \W]\$ '
# PS1="\[\e[48;2;60;120;220m\e[38;2;0;0;0m\] \W/ \[\e[0m\]\$(git rev-parse --is-inside-work-tree &>/dev/null && echo \" \[\e[3m\e[37m\](λ • #\$(git branch --show-current)\[\e[37m\])\[\e[0m\]\") "
PS1='[ \W/$(git rev-parse --is-inside-work-tree &>/dev/null && echo " \[\e[3m\e[90m\]#$(git branch --show-current)\[\e[0m\]") ] λ '

export HISTSIZE=90000
export HISTFILESIZE=20000
export HISTFILE="$XDG_STATE_HOME"/bash/history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export PATH="$HOME/.local/bin:$HOME/.luarocks/bin:$PATH"

export LS_COLORS="di=1;34:ln=1;35:so=32:pi=33:ex=31:bd=35:cd=35:su=1;32:sg=1;32:tw=34:ow=34"

alias cp="cp -rv"
alias ..="cd .."
alias ls="ls --color --group-directories-first --literal"
alias grep="rg"
alias rm="gio trash"
alias mkdir="mkdir -pv"
alias wget="wget --hsts-file=$XDG_STATE_HOME/wget-hsts"
alias yarn="yarn --use-yarnrc $XDG_CONFIG_HOME/yarn/config"

alias l="ls -a"
alias reload="source ~/.bashrc"

shopt -s autocd
shopt -s cdspell
shopt -s direxpand
shopt -s dirspell
shopt -s histappend
shopt -s checkwinsize

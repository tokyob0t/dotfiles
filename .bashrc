#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# source /usr/share/blesh/ble.sh --noattach

PS1='[\u@\h \W]\$ '

export LS_COLORS="di=1;34:ln=1;35:so=32:pi=33:ex=31:bd=35:cd=35:su=1;32:sg=1;32:tw=34:ow=34"
# export LD_PRELOAD=/usr/lib/libgtk4-layer-shell.so
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export HISTSIZE=90000
export HISTFILESIZE=20000
export PATH="$HOME/.local/bin:$HOME/.luarocks/bin:$PATH"
export EDITOR=gnome-text-editor

alias cp="cp -rv"
alias ..="cd .."
alias ls='ls --color --group-directories-first --literal'
alias grep='rg'
alias rm="gio trash"
alias mkdir="mkdir -pv"
alias jq='gojq'

alias l="ls -a"
alias reload="source ~/.bashrc"


shopt -s autocd
shopt -s cdspell
shopt -s direxpand
shopt -s dirspell
shopt -s histappend
shopt -s checkwinsize

# Binds
bind 'set completion-ignore-case on'

# Tab autocompletion
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'

# Ctrl + backspace = delete word
bind '"\x08":backward-kill-word'

# Ctrl + supr = delete word
bind '"\e[3;5~":kill-word'

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

bind '"\e[1;6D": backward-word'
bind '"\e[1;6C": forward-word'

battery() {
    upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep percentage | awk '{print $2}'
}

colors() {
    local T='•••'

    echo -e "\n                 40m     41m     42m     43m     44m     45m     46m     47m"

    for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
        '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
        '  36m' '1;36m' '  37m' '1;37m'; do
        FG=${FGs// /}
        echo -en " $FGs \e[$FG  $T  "

        for BG in 40m 41m 42m 43m 44m 45m 46m 47m; do
            echo -en " \e[$FG\e[$BG  $T  \e[0m"
        done
        echo
    done
    echo
}

extract() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz) tar xzf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) unrar x $1 ;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 ;;
            *.tbz2) tar xjf $1 ;;
            *.tgz) tar xzf $1 ;;
            *.zip) unzip $1 ;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *.deb) ar x $1 ;;
            *.tar.xz) tar xf $1 ;;
            *.tar.zst) unzstd $1 ;;
            *) echo "'$1' not supported." ;;
        esac
    else
        echo "'$1' invalid file"
    fi
}

build() {

    local filename
    filename=$(basename "$1")

    case "${filename##*.}" in
        "kt")
            kotlinc "$filename" -include-runtime -d "${filename%.*}.jar" && java -jar "${filename%.*}.jar"
            ;;
        "java")
            javac "$filename" && java "${filename%.*}"
            ;;
        "cpp")
            g++ "$filename" -o "${filename%.*}" && "./${filename%.*}"
            ;;
        "c")
            gcc "$filename" -o "${filename%.*}" && "./${filename%.*}"
            ;;
        "pas")
            fpc "$filename" && "./${filename%.*}"
            ;;
        *)
            echo "Unsupported filetype: ${filename##*.}"
            ;;
    esac
}


# [[ ${BLE_VERSION-} ]] && ble-attach

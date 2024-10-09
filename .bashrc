#!/usr/bin/bash

case $- in
*i*) ;;
*) return ;;
esac

export PYGAME_DETECT_AVX2=1
export ZED_WINDOW_DECORATIONS=client

export PATH="$HOME/.local/bin/:$HOME/.local/share/flatpak/exports/bin/:$PATH"
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=100000
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_DIRS="/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:/home/$USER/.local/share/flatpak/exports/share"
export PROMPT_COMMAND="history -a"
export MANPAGER="sh -c 'sed -r \"s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g\" | bat --language man --plain'"
export LS_COLORS="di=1;34:ln=1;35:so=32:pi=33:ex=31:bd=35:cd=35:su=1;32:sg=1;32:tw=34:ow=34"
export PROMPT_COMMAND=_update_prompt
export PYTHONPATH="$HOME/.local/lib/python3.12/site-packages/"
export GI_TYPELIB_PATH=/usr/lib/girepository-1.0/

# Alias
alias ..="cd .."
alias ls="ls --color --group-directories-first --literal"
alias l="ls -a"
alias k="killall"
alias reload="source ~/.bashrc "
alias please="sudo"
alias mkdir="mkdir -pv"
alias cp="cp -rv"
alias rm="rm -rfd"
alias grep="rg"
alias gotop="gotop --layout=minimal"
alias fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias pywal="wal"

# Shopt stuff
shopt -s autocd
shopt -s cdspell
shopt -s direxpand
shopt -s dirspell

# Binds
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'

# Tab autocompletion
bind 'TAB:menu-complete'

# Shift + Tab
bind '"\e[Z":menu-complete-backward'

# Ctrl + backspace = delete word
bind '"\x08":backward-kill-word'

# Ctrl + supr = delete word
bind '"\e[3;5~":kill-word'

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

echocolor() {
    local color="$1"             # Store the input color in a local variable
    local text="$1"              # Store the input text in a local variable
    local contrast_color="\e[0m" # By default, the text color is dark

    # Check if the color starts with "#" and remove the "#" if it's present
    if [[ $color == \#* ]]; then
        color=${color#\#}
    fi

    # Verify the color format and set the corresponding ANSI code
    if [[ $color =~ ^[0-9A-Fa-f]{6}$ ]]; then
        local background_color="\e[48;2;$(printf "%d;%d;%d" 0x${color:0:2} 0x${color:2:2} 0x${color:4:2})m"
    elif [[ $color =~ ^[0-9A-Fa-f]{8}$ ]]; then
        local background_color="\e[48;2;$(printf "%d;%d;%d;%d" 0x${color:0:2} 0x${color:2:2} 0x${color:4:2} 0x${color:6:2})m"
    elif [[ $color =~ ^0[xX][0-9A-Fa-f]+$ ]]; then
        local background_color="\e[48;5;${color#0x}m"
    else
        echo "Invalid color format. Use hex, rgb, rgba, or 0xXXXXXX format."
        return
    fi

    # Calculate the background luminance value (greater than 128 = light, less than 128 = dark)
    local r=$(($(printf "%d" 0x${color:0:2})))
    local g=$(($(printf "%d" 0x${color:2:2})))
    local b=$(($(printf "%d" 0x${color:4:2})))
    local luminance=$(((r * 299 + g * 587 + b * 114) / 1000))

    if [[ $luminance -gt 128 ]]; then
        contrast_color="\e[38;2;22;22;22m" # Light text for light backgrounds
    else
        contrast_color="\e[38;2;221;225;230m" # Dark text for dark backgrounds
    fi

    # Display the text with the custom background color and appropriate text color
    echo -e "${background_color}${contrast_color}${text}\e[0m"
}

cat() {
    local file="$1"

    if [[ -f "$file" && $(file -b --mime-type "$file") =~ ^image/ ]]; then
        imv "$file" &
        #kitty +kitten icat "$file"
    else
        bat "$file" --color always
    fi

}

battery() {
    upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep percentage | awk '{print $2}'
}

colors() {
    local T='•••' # El texto para la prueba de colores

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

comp() {

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
        echo "Extensión de archivo no admitida: ${filename##*.}"
        ;;
    esac
}

hydra() {
    clear &&
        echo \
            "    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⡀⠀⠰⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣠⣤⣀⣀⣀⣀⡀⠀⢀⣠⠀⠀⠀⠀⠀⠠⠐⠒⣒⣲⣶⣦⣽⣦⣀⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠛⠛⢿⣿⣶⣽⣿⣿⣯⣥⣀⡀⠀⠀⠀⣠⣶⣿⣿⣿⠿⠟⠿⢿⣿⣿⣿⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠻⠛⠉⠙⠻⣿⣿⣶⣍⠀⠊⢱⣿⣿⣿⡇⠀⠀⠀⠀⠈⣿⣿⣶⣽⣆⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣯⡑⠀⢸⣿⣿⣿⣿⡄⠀⠀⠀⢀⠙⠛⠛⠿⣿⣿⣦⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⢷⠀⠘⣏⠻⣿⣿⣿⣦⣤⣀⣈⣲⣤⣀⣀⡀⠛⠃⠀⠀⠀⠀⠀
⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⠀⠀⠀⠈⠔⠚⣻⣿⣿⣿⣿⣿⣿⣿⣿⣯⣝⣧⣤⣄⣀⠀⠀⠀
⠀⠀⠀⢠⣇⣴⣮⣥⣤⡀⠀⢸⣿⣿⡏⠏⠀⠀⠀⣠⣾⣿⣿⡿⠟⢿⣿⣿⣆⠈⢿⣿⠿⠿⠿⠿⣿⠀⠀⠀
⠀⠀⣠⢿⣿⡿⠿⣿⣿⣷⣅⢸⣿⣿⡇⠀⠀⠀⠔⣹⣿⣿⡏⠀⠀⠈⣿⣿⣿⡀⠀⠠⠄⣀⠀⡆⠀⠀⠀⠀
⠀⢀⣯⣾⡿⠆⠀⢸⣿⣿⣧⠉⣿⣿⣷⡀⠀⠀⢠⣿⣿⣿⣧⡀⠀⢀⣿⣿⣿⠀⠠⣲⣿⣿⣿⣿⣦⡀⠀⠀
⠀⣿⡟⠁⠀⠀⠀⣾⣿⣿⠻⠀⠘⢿⣿⣿⣦⡀⠀⢏⠻⣿⣿⣿⣆⣼⣿⣿⣿⢀⣺⣿⣿⠁⠈⣿⣷⣷⡀⠀
⠀⠀⠀⠀⠀⠀⢸⣿⣿⣇⠁⠀⠀⠀⠙⢿⣿⣿⣷⣮⣄⣹⣿⣿⣿⣿⣿⣿⡿⠀⡿⣿⣿⣄⠀⠀⠈⠹⡿⠀
⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣦⣄⣀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠘⢹⣿⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣃⣀⣠⣴⣿⣿⠏⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠲⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⠅⠀⠀⠀⠀⠀⠀⠀⠀"
    tput civis
    read -n 1
    tput cnorm
}

_update_prompt() {
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        #Starship
        PS1='\[\e]133;k;start_kitty\a\]\[\e]133;A\a\]\[\e]133;k;end_kitty\a\]\n\[\e]133;k;start_secondary_kitty\a\]\[\e]133;A;k=s\a\]\[\e]133;k;end_secondary_kitty\a\]\[\e[1;44;30m\]  \[\e[0m\]\[\e]133;k;start_suffix_kitty\a\]\[\e[5 q\]\[\e]2;\w\a\]\[\e]133;k;end_suffix_kitty\a\] '
        #Windows
        #PS1='C:${PWD//\//\\\\}> '
    else
        PS1='\[\e]133;k;start_kitty\a\]\[\e]133;A\a\]\[\e]133;k;end_kitty\a\]\n\[\e]133;k;start_secondary_kitty\a\]\[\e]133;A;k=s\a\]\[\e]133;k;end_secondary_kitty\a\]\[\e[1;41;30m\]  \[\e[0m\]\[\e]133;k;start_suffix_kitty\a\]\[\e[5 q\]\[\e]2;\w\a\]\[\e]133;k;end_suffix_kitty\a\] '
    fi
}

source /home/tokyob0t/.bash_completions/gengir.sh

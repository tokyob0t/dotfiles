export PYENV_ROOT="$HOME/.pyenv"
export LS_COLORS="di=38;5;220"
export ZSH="$HOME/.oh-my-zsh"
export PATH="/home/tokyob0t/.local/bin:$PATH"
export PATH="$PATH:$HOME/.local/share/gem/ruby/3.0.0/bin" # I use colorls B)
export PATH="$PATH:$HOME/.config/nvim/bin"
export PATH=$PATH:/home/tokyob0t/.spicetify
export PATH="$PYENV_ROOT/bin:$PATH"

DISABLE_AUTO_TITLE="true"

plugins=(
	zsh-autosuggestions
	web-search
	sudo 
)




ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#393939'

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
source $ZSH/oh-my-zsh.sh
source $(dirname $(gem which colorls))/tab_complete.sh

# Powerlevel10k settings #
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
###########################



# Aliases #
alias matrix="cmatrix"
alias gotop="gotop"
alias lolcat="dotacat"
alias neofetch='clear && sysfetch | lolcat'
alias owofetch='clear && uwufetch | lolcat'
alias reload="source ~/.zshrc"
alias wifi-menu="exec ~/.config/wofi/scripts/wifi_menu.sh"
alias bt-menu="exec ~/.config/wofi/scripts/bluetooth_menu.sh"
alias power-menu="exec ~/.config/wofi/scripts/powermenu.sh"
alias please="sudo"
alias mkdir="mkdir -pv"
alias ..="cd .."
alias cp="cp -rv"
alias rm="rm -rfd"
alias ls="colorls --sd"
alias uwu="paru"
alias code="vscodium"
alias vim="nvim"
alias vi="vim"

# Shortcuts #


bindkey '^H' backward-kill-word #Borra palabras enteras

bindkey '^Z' undo



# Functions #

cat() {
  local file="$1"

  # Verificar si el archivo es una imagen
  if [[ -f "$file" && $(file -b --mime-type "$file") =~ ^image/ ]]; then
    kitty +kitten icat "$file"
  else
    bat "$file" --color always
  fi
}


git() {
    if [[ $* == "status" ]]; then
        colorls --gs
    else
        command git "$@"
    fi
}

comp() {
    local filename
    filename=$(basename "$1")

    case "${filename##*.}" in
        "kt")
            time kotlinc "$filename" -include-runtime -d "${filename%.*}.jar" && java -jar "${filename%.*}.jar"
            ;;
        "java")
            time javac "$filename" && java "${filename%.*}"
            ;;
        "cpp")
            time g++ "$filename" -o "${filename%.*}" && "./${filename%.*}"
            ;;
        "c")
            time gcc "$filename" -o "${filename%.*}" && "./${filename%.*}"
            ;;
        *)
            echo "Extensión de archivo no admitida: ${filename##*.}"
            ;;
    esac
}

_comp() {
    _files -g "*.kt *.java *.cpp *.c" # Lista de extensiones que deseas autocompletar
}

compdef _comp comp

echocolor() {
  local color="$1"       # Store the input color in a local variable
  local text="$1"        # Store the input text in a local variable
  local contrast_color="\e[0m"  # By default, the text color is dark

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
  local luminance=$(( (r*299 + g*587 + b*114) / 1000 ))

  if [[ $luminance -gt 128 ]]; then
    contrast_color="\e[38;2;22;22;22m"  # Light text for light backgrounds
  else
    contrast_color="\e[38;2;221;225;230m"  # Dark text for dark backgrounds
  fi

  # Display the text with the custom background color and appropriate text color
  echo -e "${background_color}${contrast_color}${text}\e[0m"
}



color() {

    local T='•••'   # The text for the color test

    echo -e "\n         def     40m     41m     42m     43m     44m     45m     46m     47m";

    for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
            '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
            '  36m' '1;36m' '  37m' '1;37m';

    do FG=${FGs// /}
    echo -en " $FGs \033[$FG  $T  "
    
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
        do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
    done
    echo;
    done
    echo
}
hydra(){
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
extract () {
  if [ -f "$1" ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   unzstd $1    ;;
      *)           echo "'$1' not supported." ;;
    esac
  else
    echo "'$1' invalid file"
  fi
}

eval "$(pyenv init -)"

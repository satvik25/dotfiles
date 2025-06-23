# Lines configured by zsh-newuser-install
setopt extendedglob
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/7vik/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Pre-requisites
autoload -U colors && colors			# Required by Colors
setopt prompt_subst						# Required by Icons


####################
## GLOBAL OPTIONS ##
####################

# Miscellanous customisations
## Vertical space at the top
precmd() {
	echo	
}


# Variables
export VISUAL="micro"
export EDITOR="micro"
export SYSTEMD_EDITOR="micro"


# Commands
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dots-pull='dots pull --rebase origin master'

## Push dotfiles
dots-push() {
  # Stage changes
  dots add -u

  # Commit changes
  local msg="upd $(date '+%Y-%m-%d %H:%M:%S')"
  dots commit -m "$msg"

  # Push to origin
  dots push
}

alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

alias restore-snapshot='sudo ./.local/bin/restore_snapshot.sh'

alias edit='micro'
alias edit-hypr='micro ~/.config/hypr/hyprland.conf'
alias edit-hyprlock='micro ~/.config/hypr/hyprlock.conf'
alias edit-hypridle='micro ~/.config/hypr/hypridle.conf'
alias edit-waybar='micro ~/.config/waybar/config.jsonc'
alias edit-waybar-style='micro ~/.config/waybar/style.css'
alias edit-ulauncher-style='micro ~/.config/ulauncher/user-themes/passage/theme.css'
alias edit-kitty='micro ~/.config/kitty/kitty.conf'
alias edit-uwsm='micro ~/.config/uwsm/env'
alias edit-uwsm-hypr='micro ~/.config/uwsm/env-hyprland'
alias edit-swaync='micro ~/.config/swaync/config.json'
alias edit-swaync-style='micro ~/.config/swaync/style.css'
alias edit-sddm='sudo micro /etc/sddm.conf.d/sddm.conf'
alias edit-sddm-th='sudo micro /usr/share/sddm/themes/passage/Main.qml'
alias edit-gtk='micro ~/.config/gtk-3.0/gtk.css'
alias edit-zsh='micro ~/.zshrc'
alias edit-zprof='micro ~/.zprofile'
alias edit-iwd='sudo micro /etc/iwd/main.conf'
alias edit-nm='sudo micro /etc/NetworkManager/NetworkManager.conf'
alias edit-dns='sudo micro /etc/dnscrypt-proxy/dnscrypt-proxy.toml'

alias src-zsh='source ~/.zshrc'

alias rs-waybar='systemctl --user restart waybar'
alias rs-ulauncher='pkill ulauncher'


# Keybindings
bindkey -e

bindkey '^[[1;5D' backward-word   	# Ctrl + ←
bindkey '^[[1;5C' forward-word    	# Ctrl + →
bindkey '^[[H' beginning-of-line  	# Fn + ←
bindkey '^[[F' end-of-line			# Fn + →
bindkey '^H' backward-kill-word		# Ctrl + Backspace


# Colors
## Color commands
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color'
alias lsblk='lsblk --color'

export SUDO_PROMPT=$'\e[31m[sudo]\e[0m password for %u: '

command_not_found_handler() {
  echo $'\e[33mCommand not found: \e[0m'"$1" >&2
  return 127
}

# Skip all customisations below this line for non-interactive shells
[[ $- != *i* ]] && return




#################
## TTY OPTIONS ##
#################

# Colors
## Colored auto-complete
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

## Color man
### Enable color output in man page
export LESS='-R'
export MANROFFOPT='-c'
export MANPAGER='less -R'
### Define colors
export LESS_TERMCAP_md=$'\e[1;32m'			# Bold → Green
export LESS_TERMCAP_us=$'\e[4;33m'			# Underline → Yellow
export LESS_TERMCAP_so=$'\e[7;34m'			# Standout/reverse → Blue
### Reset styles
export LESS_TERMCAP_me=$'\e[0m'   # reset bold/standout
export LESS_TERMCAP_ue=$'\e[0m'   # reset underline
export LESS_TERMCAP_se=$'\e[0m'   # reset standout


# Prompt line
PROMPT=$'  %{\e[32m%}{ }  %{\e[0m%}'
zle_highlight=( 'default:fg=white,bold' )
RPROMPT=$'   %{\e[1;34m%}%n%{\e[0m%}  %{\e[37m%}%~ %{\e[0m%}'


# Skip graphical session customisations below this line while in tty
if { [[ -z $DISPLAY && -z $WAYLAND_DISPLAY ]] || [[ $TERM == linux ]]; }; then
  return
fi




###############################
## GRAPHICAL SESSION OPTIONS ##
###############################

# Apps
chrome() {
	setsid google-chrome-stable "${flags[@]}" "$@" >/dev/null 2>&1 &
}

ytm () {
    # 1) launch the app (backgrounded exactly as before)
    setsid google-chrome-stable \
        --user-data-dir="$HOME/.config/ytmusic-profile" \
        --profile-directory=Default \
        --app="https://music.youtube.com" \
        --class=YTMusic \
        --no-first-run --new-window \
        --enable-features=UseOzonePlatform \
        --ozone-platform=wayland \
        >/dev/null 2>&1 &

    # 2) give Hyprland a tiny moment so the window lands in this workspace
    sleep 0.1   # adjust/remove to taste

    # 3) rename the *current* workspace to the music icon
    local ws
    ws="$(hyprctl activeworkspace -j | jq -r '.id')"
    hyprctl dispatch renameworkspace "$ws" " $ws  󰎇 "
    # └─ if you turned `hypr-name` into an executable script, you could instead do:
    #    hypr-name "$ws" music
}


# Colors
## Define colors
HOST_COLOR=$(printf "\033[38;2;158;189;158m")			# Green
PROMPT_CHAR_COLOR=$(printf "\033[38;2;158;189;158m")	# Green
DIR_COLOR=$(printf "\033[38;2;180;180;180m")  			# Gray

ERROR_COLOR=$(printf "\033[38;2;245;60;60m")     		# Red
WARNING_COLOR=$(printf "\033[38;2;255;238;140m") 		# Yellow
INFO_COLOR=$(printf "\033[38;2;158;189;158m")    		# Green

RESET=$(printf "\033[0m")

## Color command not found
# command_not_found_handler() {
  # echo "${ERROR_COLOR} Command not found: ${RESET}$1" >&2
  # return 127
# }

## Color man
### Enable color output in man page
export LESS='-R'
export MANROFFOPT='-c'
export MANPAGER='less -R'
### Define colors
export LESS_TERMCAP_md=$'\e[38;2;158;189;158m'         	# 9ebd9e for emboldened items
export LESS_TERMCAP_us=$'\e[4m\e[38;2;207;207;196m'     # cfcfc4 for underlined items
### Reset styles
export LESS_TERMCAP_me=$'\e[0m'  # end bold
export LESS_TERMCAP_ue=$'\e[0m'  # end underline
export LESS_TERMCAP_se=$'\e[0m'  # end standout (not used, but safe)


# Icons
## Prompt line
### Define prompt line icons
if [[ $EUID -eq 0 ]]; then
  PROMPT_SYMBOL="󰅴"
else
  PROMPT_SYMBOL=""
fi
 
ICON_ROOT=""
ICON_HOME="󰴖"
ICON_DL="󰄠"

DIRPATH_ROOT="/"
DIRPATH_HOME="$HOME"
DIRPATH_DL="$HOME/Downloads"

### Set prompt line icons
DIR_ICON() {
  local dir=$PWD

  # Inside root
  if [[ "$dir" == "$DIRPATH_ROOT" ]]; then
    local rel=${dir#"$DIRPATH_ROOT"}
    print -n "${ICON_ROOT}${rel}"
    return
  fi
  
  # Inside Downloads
  if [[ "$dir" == "$DIRPATH_DL" ]]; then
    local rel=${dir#"$DIRPATH_DL"}
    print -n "${ICON_DL}${rel}"
    return
  fi

  # Inside Downloads subdirs
  if [[ "$dir" == $DIRPATH_DL/* ]]; then
    local rel=${dir#"$DIRPATH_DL"}
    print -n "${ICON_DL} ${rel}"
    return
  fi

  # Inside home
  if [[ "$dir" == "$HOME" ]]; then
    local rel=${dir#"$HOME"}
    print -n "${ICON_HOME}${rel}"
    return
  fi

  # Inside home subdirs
  if [[ "$dir" == $HOME/* ]]; then
  	local rel=${dir#"$HOME"}
  	print -n "${ICON_HOME} ${rel}"
	return
  fi
  
  # Normal fallback/ inside root subdirs
  #print -P "%~"
  local rel=${dir#"$DIRPATH_ROOT"}
  print -n "${ICON_ROOT} ${rel:+/$rel}"
}


## Hyprland workspace icons
### Define icon keywords
typeset -A HYPR_WS_ICONS=(
  # keyword   icon
    music     "󰎇"
    web       "󰖟"
    code      "󰅩"
)
### Rename workspaces
hypr-name () {
    # Checks at least 2 args are present
    if [[ $# -lt 2 ]]; then
        print -u2 "Usage: hypr-name <workspace-number> <keyword|name> [name]"
        return 1
    fi
    # Args
    local ws="$1"        # first argument: workspace number
    shift

    local label_parts=()
    local icon_replaced=0
    local icon_value=""

    for arg in "$@"; do
        if [[ $icon_replaced -eq 0 && -n ${HYPR_WS_ICONS[$arg]} ]]; then
            icon_value="${HYPR_WS_ICONS[$arg]}"
            label_parts+=("$icon_value")
            icon_replaced=1
        else
            label_parts+=("$arg")
        fi
    done

    # Build the label string:
    local label=""
	# For less space after icon and before word
    # for ((i = 1; i <= ${#label_parts[@]}; ++i)); do
    #     if [[ $i -eq 1 ]]; then
    #         label="${label_parts[i]}"
    #     elif [[ "${label_parts[i]}" == "$icon_value" ]]; then
    #         label+="  ${label_parts[i]}"   	# two spaces before icons
    #     else
    #         label+=" ${label_parts[i]}"		# two spaces before words
    #     fi
    # done
	# For more space after icon and before word
    local after_icon=0
    for ((i = 1; i <= ${#label_parts[@]}; ++i)); do
        if [[ $i -eq 1 ]]; then
            label="${label_parts[i]}"
        elif [[ "${label_parts[i]}" == "$icon_value" ]]; then
            label+="  ${label_parts[i]}"     # two spaces before the icon (if not first)
            after_icon=1
        elif [[ $after_icon -eq 1 ]]; then
            label+="  ${label_parts[i]}"     # two spaces before the first word after icon
            after_icon=0
        else
            label+=" ${label_parts[i]}"
        fi
    done

    # Add one leading and one trailing space
    label=" $label "

    # Command to rename workspace
    hyprctl dispatch renameworkspace "$ws" "$label"
}


# Graphical session prompt line
PROMPT="  %{$PROMPT_CHAR_COLOR%}${PROMPT_SYMBOL}  %{$RESET%}"
zle_highlight=( 'default:fg=#9ebd9e' )
RPROMPT='   %{$HOST_COLOR%}%n %{$RESET%} %{$DIR_COLOR%}$(DIR_ICON) %{$RESET%}'

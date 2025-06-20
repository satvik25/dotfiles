# Lines configured by zsh-newuser-install
setopt extendedglob
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/7vik/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


# Avoid customisations in non-interactive shells
[[ $- != *i* ]] && return


# Miscellanous customisations
## Vertical space at the top
precmd() {
	echo	
}


# Colors
autoload -U colors && colors

## Permission level icon
if [[ $EUID -eq 0 ]]; then
  PROMPT_SYMBOL="󰅴"
else
  PROMPT_SYMBOL=""
fi

## Define colors
HOST_COLOR=$(printf "\033[38;2;158;189;158m")			# Green
PROMPT_CHAR_COLOR=$(printf "\033[38;2;158;189;158m")	# Green
DIR_COLOR=$(printf "\033[38;2;180;180;180m")  			# Gray

ERROR_COLOR=$(printf "\033[38;2;245;60;60m")     		# Red
WARNING_COLOR=$(printf "\033[38;2;255;238;140m") 		# Yellow
INFO_COLOR=$(printf "\033[38;2;158;189;158m")    		# Green

RESET=$(printf "\033[0m")

## Color persisent text
PROMPT="  %{$PROMPT_CHAR_COLOR%}${PROMPT_SYMBOL}  %{$RESET%}"
RPROMPT="%{$HOST_COLOR%}%n %{$RESET%}%{$DIR_COLOR%}%~ %{$RESET%}"

## Colored auto-complete
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

## Color command not found
command_not_found_handler() {
  echo "${ERROR_COLOR} Command not found: ${RESET}$1" >&2
  return 127
}

## Color commands
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color'
alias lsblk='lsblk --color'

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


# Keybindings
bindkey -e

bindkey '^[[1;5D' backward-word   	# Ctrl + ←
bindkey '^[[1;5C' forward-word    	# Ctrl + →
bindkey '^[[H' beginning-of-line  	# Fn + ←
bindkey '^[[F' end-of-line			# Fn + →
bindkey '^H' backward-kill-word		# Ctrl + Backspace


# Aliases
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dots-pull='dots pull --rebase origin master'

alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

alias restore-snapshot='sudo ./.local/bin/restore_snapshot.sh'

alias edit-hypr='micro ~/.config/hypr/hyprland.conf'
alias edit-waybar='micro ~/.config/waybar/config.jsonc'
alias edit-waybar-style='micro ~/.config/waybar/style.css'
alias edit-kitty='micro ~/.config/kitty/kitty.conf'
alias edit-uwsm='micro ~/.config/uwsm/env'
alias edit-uwsm-hypr='micro ~/.config/uwsm/env-hyprland'
alias edit-gtk='micro ~/.config/gtk-3.0/gtk.css'
alias edit-zsh='micro ~/.zshrc'
alias edit-zprof='micro ~/.zprofile'

alias src-zsh='source ~/.zshrc
'
alias rs-waybar='systemctl --user restart waybar'

# Apps
chrome() {
	setsid google-chrome-stable "${flags[@]}" "$@" >/dev/null 2>&1 &
}

ytm() {
	setsid google-chrome-stable \
    --user-data-dir="$HOME/.config/ytmusic-profile" \
    --profile-directory=Default \
    --app="https://music.youtube.com" \
    --class=YTMusic \
    --no-first-run --new-window \
    --enable-features=UseOzonePlatform \
    --ozone-platform=wayland \
    >/dev/null 2>&1 &
}

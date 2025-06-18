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

# Keybindings
bindkey -e

bindkey '^[[1;5D' backward-word   	# Ctrl + ←
bindkey '^[[1;5C' forward-word    	# Ctrl + →
bindkey '^[[H' beginning-of-line  	# Fn + ←
bindkey '^[[F' end-of-line			# Fn + →
bindkey '^H' backward-kill-word		# Ctrl + Backspace


# Set the prompt symbol
if [[ $EUID -eq 0 ]]; then
  PROMPT_SYMBOL="󰅴"
else
  PROMPT_SYMBOL=""
fi


# Colors
autoload -U colors && colors

HOST_COLOR=$(printf "\033[38;2;158;189;158m")			# Green
PROMPT_CHAR_COLOR=$(printf "\033[38;2;207;207;196m")	# Gray
DIR_COLOR=$(printf "\033[38;2;180;180;180m")  			# Gray
ERROR_COLOR=$(printf "\033[38;2;245;60;60m")     		# Red
WARNING_COLOR=$(printf "\033[38;2;255;238;140m") 		# Yellow
INFO_COLOR=$(printf "\033[38;2;158;189;158m")    		# Green
RESET=$(printf "\033[0m")

PROMPT="%{$HOST_COLOR%} ${PROMPT_SYMBOL}%{$RESET%} "
RPROMPT="%{$HOST_COLOR%}%n%{$RESET%} %{$DIR_COLOR%}%~%{$RESET%}"

command_not_found_handler() {
  echo "${ERROR_COLOR} Command not found: ${RESET}$1" >&2
  return 127
}

# Vertical space at the top
echo



# Aliases
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dots-pull='dots pull --rebase origin master'

alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

alias restore-snapshot='sudo ./.local/bin/restore_snapshot.sh'

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color'
alias lsblk='lsblk --color'

alias edit-hypr='micro ~/.config/hypr/hyprland.conf'


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

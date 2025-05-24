# Lines configured by zsh-newuser-install
setopt extendedglob
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/7vik/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

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

alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

GTK_IM_MODULE=ibus
QT_IM_MODULE=ibus
XMODIFIERS=@im=ibus

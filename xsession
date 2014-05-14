#!/bin/sh

# Setup PATH
export PATH=$HOME/bin:/sbin:/usr/local/sbin:/usr/sbin:/bin:/usr/local/bin:/usr/bin:/usr/local/games:/usr/games

# Setup locale
export LANG=fr_FR.utf8
export LC_MESSAGES=en_US.utf8

# Ensure we use the appropriate gtkrc-2.0 file
export GTK2_RC_FILES=$HOME/.gtkrc-2.0

# Java fonts are ugly by default
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=lcd'
export _JAVA_AWT_WM_NONREPARENTING=1

# We do not want to rely on crappy mailcap
export MAILCAPS=$HOME/.mailcap

# Environment variables
[ -e ~/.zsh/env ] && . ~/.zsh/env

# GDM move Xauthority in some obscure place
# See:
#  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=614972
#  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=586685
[ "$XAUTHORITY" = $HOME/.Xauthority ] || {
    XAUTHORITY=$HOME/.Xauthority xauth merge $XAUTHORITY
    export XAUTHORITY=$HOME/.Xauthority
}

case "$(hostname)" in
    neo)
        xrandr --output HDMI1 --auto --output HDMI2 --auto --right-of HDMI1
        ;;
    alucard)
        xrandr --output DVI-0 --auto --primary --output DisplayPort-0 --auto --right-of DVI-0
        ;;
esac

[ -x /usr/sbin/rfkill ] && rfkill block all 2> /dev/null
[ -x /usr/bin/xbacklight ] && xbacklight = 60 2> /dev/null
[ -x /usr/bin/redshift ] && redshift -l 2.3508:48.8567 -t 6500:5500 2> /dev/null &

exec awesome

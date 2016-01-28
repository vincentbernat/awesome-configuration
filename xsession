#!/bin/sh

# Setup PATH
export PATH=$HOME/bin:/sbin:/usr/local/sbin:/usr/sbin:/bin:/usr/local/bin:/usr/bin:/usr/local/games:/usr/games

# Setup locale
export LANG=fr_FR.utf8
export LC_MESSAGES=en_US.utf8

# Ensure we use the appropriate gtkrc-2.0 file
export GTK2_RC_FILES=$HOME/.gtkrc-2.0

# Java incompatibility with awesome
export _JAVA_AWT_WM_NONREPARENTING=1

# We do not want to rely on crappy mailcap
export MAILCAPS=$HOME/.mailcap

# Workaround a bug in XI focus-in events. See:
#  https://bugzilla.gnome.org/show_bug.cgi?id=677329
export GDK_CORE_DEVICE_EVENTS=1

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

systemctl --user import-environment

case "$(hostname)" in
    neo)
        xrandr --output HDMI1 --auto --output HDMI2 --auto --right-of HDMI1
        ;;
    zoro)
        xrandr --output eDP1 --auto --dpi 144
        ;;
esac

. ~/.config/awesome/bin/xsettingsd-setup
~/.config/awesome/bin/xss-lock start &
inputplug -0 -c ~/.config/awesome/bin/input-event 2> /dev/null
rfkill block all 2> /dev/null
redshift -l 6.606:46.525 -t 6500:5500 2> /dev/null &

exec awesome

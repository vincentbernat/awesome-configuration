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
        xrandr --output HDMI-0 --auto --output DP-0 --auto --right-of HDMI-0 --dpi 192
        ;;
    zoro)
        xrandr --output eDP1 --auto --dpi 144
        ;;
esac

. ~/.config/awesome/bin/xsettingsd-setup
~/.config/awesome/bin/xss-lock start &
inputplug -0 -c ~/.config/awesome/bin/input-event 2> /dev/null
nmcli radio all off
rfkill block all 2> /dev/null
redshift -l 6.666:46.533 -t 6500:3900 2> /dev/null &
systemd-run -q --scope --user tmux start-server

case $(glxinfo | awk -F': ' '($1 == "OpenGL vendor string") {print $2}') in
    "NVIDIA Corporation")
        compton --daemon --backend glx --refresh-rate 60 --vsync opengl-swc --glx-no-stencil --glx-swap-method 4
        ;;
    *)
        compton --daemon --backend glx --xrender-sync --xrender-sync-fence --vsync opengl-swc --paint-on-overlay
        ;;
esac



exec awesome

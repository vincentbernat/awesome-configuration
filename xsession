#!/bin/sh

# Setup locale
export LANG=fr_FR.utf8
export LC_MESSAGES=en_US.utf8

# Ensure we use the appropriate gtkrc-2.0 file
export GTK2_RC_FILES=$HOME/.gtkrc-2.0

# Java incompatibility with awesome
export _JAVA_AWT_WM_NONREPARENTING=1

# We do not want to rely on crappy mailcap
export MAILCAPS=$HOME/.mailcap

# Make QT automatically scale according to screen DPI
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# Environment variables
[ -e ~/.zshenv ] && . ~/.zshenv

systemctl --user import-environment

case "$(hostname)" in
    neo)
        xrandr --output HDMI-0 --auto --primary --output DP-0 --auto --right-of HDMI-0 --dpi 192
        ;;
    zoro)
        xrandr --output eDP1 --auto --dpi 144
        ;;
esac

. ~/.config/awesome/bin/xsettingsd-setup
~/.config/awesome/bin/xss-lock start &
xiccd --edid &
inputplug -0 -c ~/.config/awesome/bin/input-event 2> /dev/null
nmcli radio all off
rfkill block all 2> /dev/null
redshift -l 6.666:46.533 -t 6500:3900 2> /dev/null &
systemd-run -q --scope --user tmux start-server
compton --daemon --backend glx --xrender-sync --xrender-sync-fence --vsync opengl-swc --paint-on-overlay

exec awesome

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

# GDM move Xauthority in some obscure place
# See:
#  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=614972
#  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=586685
[ "$XAUTHORITY" = $HOME/.Xauthority ] || {
    XAUTHORITY=$HOME/.Xauthority xauth merge $XAUTHORITY
    export XAUTHORITY=$HOME/.Xauthority
}

[ -x /usr/sbin/rfkill ] && rfkill block all 2> /dev/null
[ -x /usr/bin/xbacklight ] && xbacklight = 60 2> /dev/null

# Configure gnome-terminal

gnoterm() {
    gconftool-2 --type $1 --set /apps/gnome-terminal/profiles/Default/$2 $3
}
gnoterm int    scrollback_lines      5000
gnoterm bool   scroll_on_output      false
gnoterm bool   scroll_on_keystroke   true
gnoterm bool   default_show_menubar  false
gnoterm string cursor_blink_mode     on
gnoterm bool   use_system_font       false
gnoterm string font                  "DejaVu Sans Mono 8"
gnoterm bool   use_theme_colors      false
gnoterm float  background_darkness   0.92
gnoterm string background_type       transparent
gnoterm string foreground_color      "#FFFFFF"
gnoterm string background_color      "#000000"
gnoterm string palette \
    $(sed -n 's/^.color\([0-9]*\): /\1/p' ~/.Xresources | sort -n | \
      awk '{print $2}' | tr '\n' ':' | sed 's/:$//')


exec awesome

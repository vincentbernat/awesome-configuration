#!/bin/sh

# Ensure we use the appropriate gtkrc-2.0 file
export GTK2_RC_FILES=$HOME/.gtkrc-2.0

# Java incompatibility with awesome
export _JAVA_AWT_WM_NONREPARENTING=1

# We do not want to rely on crappy mailcap
export MAILCAPS=$HOME/.mailcap

# Make QT automatically scale according to screen DPI
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_QPA_PLATFORMTHEME=qt5ct

# GTK3 apps try to contact org.a11y.Bus. Disable that.
export NO_AT_BRIDGE=1

# Environment variables
unset LC_ALL
[ -e ~/.zshenv ] && . ~/.zshenv

# Services are started with systemd
systemctl --user import-environment
mkdir -p ~/.config/systemd
ln -nsf ~/.config/awesome/systemd ~/.config/systemd/user
systemctl --user daemon-reload
exec systemctl --user start --wait xsession@$(systemd-escape -- "$DISPLAY").target

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

# GTK3 apps try to contact org.a11y.Bus. Disable that.
export NO_AT_BRIDGE=1

# Environment variables
[ -e ~/.zshenv ] && . ~/.zshenv

# Services are started with systemd
systemctl --user import-environment
mkdir -p ~/.config/systemd
ln -nsf ~/.config/awesome/systemd ~/.config/systemd/user
systemctl --user daemon-reload
exec systemctl --user start --wait xsession@$(systemd-escape -- "$DISPLAY").target

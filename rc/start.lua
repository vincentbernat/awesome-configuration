-- Spawn a composoting manager
awful.util.spawn("compton", false)
awful.util.spawn("xcompmgr", false) -- Will fail if compton has been started

-- Start idempotent commands
local execute = {
   -- Start PulseAudio
   "pulseaudio --check || pulseaudio -D",
   "xset -b",	-- Disable bell
   -- Enable numlock
   "numlockx on",
   -- Read resources
   "xrdb -merge " .. awful.util.getdir("config") .. "/Xresources",
   -- Default browser
   "xdg-mime default " .. config.browser .. ".desktop " ..
      "x-scheme-handler/http " ..
      "x-scheme-handler/https " ..
      "text/html",
   -- Default MIME types
   "xdg-mime default evince.desktop application/pdf",
   "xdg-mime default gpicview.desktop image/png image/x-apple-ios-png image/jpeg image/jpg image/gif"
}

-- Keyboard/Mouse configuration
if config.hostname == "zoro" then
   execute = awful.util.table.join(
      execute, {
	 -- Keyboard and mouse
	 "setxkbmap us,fr '' compose:ralt grp:rctrl_rshift_toggle",
	 "xmodmap -e 'keycode 110 = Control_L'", -- home
	 "xmodmap -e 'keycode 115 = Control_L'", -- end
	 "xmodmap -e 'add control Control_L Control_R'",
	 "xmodmap -e 'keycode 49 = Insert", -- between alt_l and ctrl_l
	 "xmodmap -e 'keycode 9 = grave asciitilde'", -- escape
	 -- Wheel emulation
	 "xinput set-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation' 1",
	 "xinput set-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation Button' 2",
	 "xinput set-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation Axes' 6 7 4 5",
	 -- Make touchpad buttons work
	 "xinput set-prop 'SynPS/2 Synaptics TouchPad' 'Synaptics Soft Button Areas' 3656 5112 0 2200 2928 3656 0 2200",
	 "xinput set-prop 'SynPS/2 Synaptics TouchPad' 'Synaptics Area' 0 0 2200 0"})
end

os.execute(table.concat(execute, ";"))

-- Spawn various X programs
xrun("polkit-gnome-authentication-agent-1",
     "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")
xrun("pidgin", "pidgin -n")
xrun("keepassx", "keepassx -min -lock")
xrun("NetworkManager Applet", "nm-applet")

if config.hostname == "neo" then
   xrun("transmission", "transmission-gtk -m")
end

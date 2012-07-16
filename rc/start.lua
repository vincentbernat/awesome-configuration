-- Startup

-- Setup display
local xrandr = {
   naruto = "--output VGA1 --auto --output DVI1 --auto --left-of VGA1",
   neo    = "--output HDMI-0 --auto --output DVI-0 --auto --right-of HDMI-0"
}
if xrandr[config.hostname] then
   os.execute("xrandr " .. xrandr[config.hostname])
end

-- Spawn a composoting manager
awful.util.spawn("xcompmgr", false)

-- Start idempotent commands
local execute = {
   -- Start PulseAudio
   "pulseaudio --check || pulseaudio -D",
   "xset -b",	-- Disable bell
   -- Enable numlock
   "numlockx on",
   -- Read resources
   "xrdb -merge " .. awful.util.getdir("config") .. "/Xresources",
}

if config.hostname == "naruto" then
   execute = awful.util.table.join(
      execute, {
	 "xset m 4 3",	-- Mouse acceleration
	       })
elseif config.hostname == "neo" then
   execute = awful.util.table.join(
      execute, {
	 -- Keyboard configuration
	 "xset m 3 3",	-- Mouse acceleration
	       })
elseif config.hostname == "guybrush" then
   execute = awful.util.table.join(
      execute, {
	 -- Wheel emulation
	 "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation' 8 1",
	 "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation Button' 8 2",
	 "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation Axes' 8 6 7 4 5",
	 -- Disable touchpad
	 "xinput set-int-prop 'SynPS/2 Synaptics TouchPad' 'Synaptics Off' 8 1"})
end

os.execute(table.concat(execute, ";"))

-- Spawn various X programs
xrun("polkit-gnome-authentication-agent-1",
     "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")
xrun("Bluetooth Applet",
     "bluetooth-applet")
xrun("pidgin", "pidgin -n")
xrun("emacs")

if config.hostname == "neo" then
   xrun("keepassx", "keepassx -min -lock")
   xrun("transmission", "transmission-gtk -m")
   xrun("chromium")
elseif config.hostname == "guybrush" then
   xrun("keepassx", "keepassx -min -lock")
   xrun("NetworkManager Applet", "nm-applet")
   xrun("chromium")
elseif config.hostname == "naruto" then
   xrun("iceweasel")
end

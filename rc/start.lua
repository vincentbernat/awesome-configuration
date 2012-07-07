-- Startup

-- run a command only if the client does not already exist
xrun = function(name, cmd)
   if os.execute("xwininfo -name '" .. name .. "' > /dev/null 2> /dev/null") == 0 then
      return
   end
   awful.util.spawn_with_shell(cmd or name)
end

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
}

if config.hostname == "naruto" then
   execute = awful.util.table.join(
      execute, {
	 -- Keyboard configuration
	 "xset m 4 3",	-- Mouse acceleration
	 "setxkbmap us '' compose:rwin ctrl:nocaps",
	 "xmodmap -e 'keysym Pause = XF86ScreenSaver'" })
elseif config.hostname == "neo" then
   execute = awful.util.table.join(
      execute, {
	 -- Keyboard configuration
	 "xset m 3 3",	-- Mouse acceleration
	 "setxkbmap us '' compose:rwin ctrl:nocaps",
	 "xmodmap -e 'keysym Pause = XF86ScreenSaver'"})
elseif config.hostname == "guybrush" then
   execute = awful.util.table.join(
      execute, {
	 -- Keyboard configuration
	 "setxkbmap us '' compose:rctrl ctrl:nocaps",
	 "xmodmap -e 'keysym XF86AudioPlay = XF86ScreenSaver'",
	 -- Wheel emulation
	 "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation' 8 1",
	 "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation Button' 8 2",
	 "xinput set-int-prop 'TPPS/2 IBM TrackPoint' 'Evdev Wheel Emulation Axes' 8 6 7 4 5",
	 -- Disable touchpad
	 "xinput set-int-prop 'SynPS/2 Synaptics TouchPad' 'Synaptics Off' 8 1"})
end

os.execute(table.concat(execute, ";"))

-- Spawn various X programs
startapps = function()
   xrun("polkit-gnome-authentication-agent-1",
	"/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")
   xrun("Bluetooth Applet",
	"bluetooth-applet")
   
   if config.hostname == "naruto" then
      xrun("Pidgin", "pidgin")
   elseif config.hostname == "neo" then
      xrun("Pidgin", "pidgin")
      xrun("keepassx", "keepassx -min -lock")
      xrun("Transmission", "transmission-gtk -m")
   elseif config.hostname == "guybrush" then
      xrun("keepassx", "keepassx -min -lock")
      -- xrun("nm-applet")
   end
end

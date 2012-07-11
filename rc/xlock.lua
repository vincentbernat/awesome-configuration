-- Lockscreen

xrun("xautolock",
     "xautolock -time 3 -locker 'i3lock -n -i " ..
	awful.util.getdir("cache") .. "/current-wallpaper.png'")

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({}, "XF86ScreenSaver", function() awful.util.spawn("xautolock -locknow", false) end))

-- Configure DPMS
os.execute("xset dpms 360 720 1200")

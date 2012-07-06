-- Lockscreen

xrun("xautolock",
     "xautolock -time 5 -locker 'i3lock -n -i " ..
	awful.util.getdir("cache") .. "/current-wallpaper.png'")

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({}, "XF86ScreenSaver", function() awful.util.spawn("xautolock -locknow", false) end))

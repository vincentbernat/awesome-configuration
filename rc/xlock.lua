-- Lockscreen

local icons = loadrc("icons", "vbe/icons")

xrun("xautolock",
     "xautolock -notify 10 -notifier " ..
	" 'notify-send Lock\\ screen -i " ..
	icons.lookup({name = "system-lock-screen", type = "actions" }) ..
	" -t 10000 " ..
	"   Lock\\ screen\\ will\\ be\\ started\\ in\\ 10\\ seconds...' " ..
	" -time 3 -locker " ..
	" 'i3lock -n -i " .. awful.util.getdir("cache") .. "/current-wallpaper.png'")

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({}, "XF86ScreenSaver", function() awful.util.spawn("xautolock -locknow", false) end))

-- Configure DPMS
os.execute("xset dpms 360 720 1200")

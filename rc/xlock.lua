-- Lockscreen

local icons = loadrc("icons", "vbe/icons")

xrun("xautolock",
     awful.util.getdir("config") ..
        "/bin/xautolock " ..
        icons.lookup({name = "system-lock-screen", type = "actions" }))

local lock = function()
   awful.util.spawn(awful.util.getdir("config") ..
                    "/bin/locker", false)
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({}, "XF86ScreenSaver", lock),
   awful.key({ modkey, }, "Delete", lock))

-- Configure DPMS
os.execute("xset -dpms")

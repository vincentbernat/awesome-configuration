-- Lockscreen

local lock = function()
   os.execute("xset s activate")
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({}, "XF86ScreenSaver", lock),
   awful.key({ modkey, }, "Delete", lock))

-- Configure xss-lock
os.execute(awful.util.spawn(awful.util.getdir("config") ..
                            "/bin/xss-lock start"))

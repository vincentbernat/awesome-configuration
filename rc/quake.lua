local quake = loadrc("quake", "vbe/quake")

local quakeconsole = {}
for s = 1, screen.count() do
   quakeconsole[s] = quake({ terminal = config.terminal,
			     height = 0.3,
			     screen = s })
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "`",
	     function () quakeconsole[mouse.screen]:toggle() end,
	     "Toggle Quake console"))

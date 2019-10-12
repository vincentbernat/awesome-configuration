local quake = loadrc("quake", "vbe/quake")
local quakeconsole = quake({ terminal = config.terminal,
                             argname = "--name %s",
			     height = 0.3 })

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "`",
	     function () quakeconsole:toggle() end,
	     "Toggle Quake console"))

-- Keyboard configuration with kbdd

local icons = loadrc("icons", "vbe/icons")

-- Global configuration
if config.hostname == "guybrush" then
   os.execute("setxkbmap us,fr '' compose:rctrl ctrl:nocaps")
else
   os.execute("setxkbmap us,fr '' compose:rwin ctrl:nocaps")
end

-- Additional mappings
local mappings = { Pause = "XF86ScreenSaver" }
if config.hostname == "guybrush" then
   mappings = { XF86AudioPlay = "XF86ScreenSaver" }
end



local function update_mappings()
   for src, dst in pairs(mappings) do
      os.execute(string.format("xmodmap -e 'keysym %s = %s'", src, dst))
   end
end

local qdbus = {
   check = "qdbus ru.gentoo.KbddService /ru/gentoo/KbddService",
   next  = "qdbus ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.next_layout"
}

-- Display a notification if the layout changed
local nid = nil
dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutNameChanged'")
dbus.add_signal("ru.gentoo.kbdd",
		function(...)
		   local data = {...}
		   local layout = data[2]
		   update_mappings()
		   nid = naughty.notify({ title = "Keyboard layout changed",
					  text = "New layout is <i>" .. layout .. "</i>",
					  replaces_id = nid,
					  icon = icons.lookup({ name = "keyboard",
								type = "devices" }),
					  screen = client.focus.screen }).id
		end)

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "=",
	     function()
		os.execute(qdbus.next)
	     end, "Change keyboard layout"))

-- Run kbdd if not running
if os.execute(qdbus.check .. " 2> /dev/null > /dev/null") ~= 0 then
   awful.util.spawn("kbdd")
end

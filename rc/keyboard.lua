-- Keyboard configuration with kbdd

local icons = loadrc("icons", "vbe/icons")

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
		   local screen = mouse.screen
		   if client.focus then screen = client.focus.screen end
		   nid = naughty.notify({ title = "Keyboard layout changed",
					  text = "New layout is <i>" .. layout .. "</i>",
					  replaces_id = nid,
					  icon = icons.lookup({ name = "keyboard",
								type = "devices" }),
					  screen = screen }).id
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

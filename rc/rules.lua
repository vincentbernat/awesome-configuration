local icons = loadrc("icons", "vbe/icons")

awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = { border_width = beautiful.border_width,
		    border_color = beautiful.border_normal,
		    focus = true,
		    maximized_vertical   = false,
		    maximized_horizontal = false,
                    keys = config.keys.client,
		    buttons = config.mouse.client }},
   -- i3lock
   { rule = { name = "i3lock" },
     properties = { ontop = true } },
   -- Browser stuff
   { rule = { role = "browser" },
     callback = function(c)
	if not c.icon then
	   local icon = icons.lookup({ name = "web-browser",
				       type = "apps" })
	   if icon then
	      c.icon = image(icon)
	   end
	end
     end },
   { rule = { class = config.termclass },
     properties = { icon = image(icons.lookup({ name = "gnome-terminal",
                                                type = "apps" })) } },
   { rule_any = { class = { "Iceweasel", "Firefox", "Chromium", "Conkeror", "Google-chrome" } },
     callback = function(c)
	-- All windows should be slaves, except the browser windows.
	if c.role ~= "browser" then awful.client.setslave(c) end
     end },
   -- See also tags.lua
   -- Pidgin
   { rule = { class = "Pidgin" },
     except = { role = "buddy_list" },
     properties = { }, callback = awful.client.setslave },
   { rule = { class = "Pidgin", role = "buddy_list" },
     properties = { }, callback = awful.client.setmaster },
   -- Shadow
   { rule = { class = "Shadow" },
     properties = { fullscreen = true }},
   -- Zoom dialogs should not have focus
   { rule = { class = "zoom", type = "dialog" },
     properties = { focus = false }},
   -- Should not be master
   { rule_any = { class =
		  { config.termclass,
		    "Transmission-gtk"
		  }, instance = { "Download" }},
     except = { icon_name = "QuakeConsoleNeedsUniqueName" },
     properties = { },
     callback = awful.client.setslave },
   -- Floating windows
   { rule_any = { class = { "Display.im6", "Key-mon", "Picture-in-Picture" } },
     properties = { floating = true }},
}

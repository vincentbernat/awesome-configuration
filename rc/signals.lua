local icons = loadrc("icons", "vbe/icons")

-- Did we get the focus because of sloppy focus?
local focus_from_mouse = false
local function mouse_follow_focus(c)
   -- Move the mouse to the top left corner
   local margin = 10
   if c.type ~= "dialog" then
      local cc = c:geometry()
      local _, x, y = awful.mouse.client.corner(nil, "top_left")
      if x and y and cc.width > margin * 2 and cc.height > margin * 2 then
	 mouse.coords({ x = x + margin , y = y + margin }, true)
      end
   end
end

-- Signal function to execute when a new client appears.
client.add_signal("manage",
		  function (c, startup)
		     -- Enable sloppy focus
		     c:add_signal("mouse::enter",
				  function(c)
				     -- If magnifier suit, only give sloppy focus to master window
				     if ((awful.layout.get(c.screen) ~= awful.layout.suit.magnifier or
					  awful.client.getmaster(c.screen) == c)
					 -- Don't give focus to a client already having focus
					 and client.focus ~= c
					 -- Don't give focus to a window that does not want focus
					 and awful.client.focus.filter(c)) then
					 focus_from_mouse = c
					 client.focus = c
				     end
				  end)

		     -- If a window change its geometry, track it with the mouse
		     c:add_signal("property::geometry",
				  function()
				 if client.focus == c then
				    mouse_follow_focus(c)
				 end
				  end)

		     -- Setup icon if none exists
		     if not c.icon then
			local icon = icons.lookup({ name = { c.class, c.instance },
						    type = "apps" })
			if icon then
			   c.icon = image(icon)
			end
		     end
		     
		     if not startup then
			-- Put windows in a smart way, only if they does not set an initial position.
			if not c.size_hints.user_position and not c.size_hints.program_position then
			   awful.placement.no_overlap(c)
			   awful.placement.no_offscreen(c)
			end
		     end
		  end)

client.add_signal("focus", function(c)
		     c.border_color = beautiful.border_focus
		     c.opacity = 1

		     if focus_from_mouse ~= c then
			mouse_follow_focus(c)
		     end
		     focus_from_mouse = false
					 
			   end)
client.add_signal("unfocus", function(c)
		     c.border_color = beautiful.border_normal
		     c.opacity = 0.85
			     end)

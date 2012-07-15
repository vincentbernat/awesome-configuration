local icons = loadrc("icons", "vbe/icons")

-- Signal function to execute when a new client appears.
client.add_signal("manage",
		  function (c, startup)
		     -- Enable sloppy focus
		     c:add_signal("mouse::enter",
				  function(c)
				     if ((awful.layout.get(c.screen) ~= awful.layout.suit.magnifier or awful.client.getmaster(c.screen) == c)
					 and awful.client.focus.filter(c)) then
					 client.focus = c
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
			   end)
client.add_signal("unfocus", function(c)
		     c.border_color = beautiful.border_normal
		     c.opacity = 0.85
			     end)

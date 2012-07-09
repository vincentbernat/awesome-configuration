-- Tags

loadrc("sharetags")

local tags = { names = { 1, "emacs", "www", "im", 5, 6, 7 },
	       layout = { awful.layout.suit.tile,
			  awful.layout.suit.tile,
			  awful.layout.suit.tile,
			  awful.layout.suit.tile,
			  awful.layout.suit.tile,
			  awful.layout.suit.tile,
			  awful.layout.suit.tile }}
tags = sharetags.create_tags(tags.names, tags.layout)
config.tags = {}

-- Compute the maximum number of digit we need, limited to 9
keynumber = math.min(9, #tags)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, #tags do
   config.tags[tags[i].name] = tags[i]
   if tags[i].name ~= tostring(i) then
      tags[i].name = tostring(i) .. "↭" .. tags[i].name
   end
   if i <= keynumber then
      config.keys.global = awful.util.table.join(
	 config.keys.global,
	 awful.key({ modkey }, "#" .. i + 9,
		   function ()
		      local t = tags[i]
		      if t.screen ~= mouse.screen then
			 if t.selected then
			    -- This tag is selected on another screen, let's swap
			    local currents = awful.tag.selectedlist(mouse.screen)
			    for _,current in pairs(currents) do
			       sharetags.tag_move(current, t.screen)
			    end
			    awful.tag.viewmore(currents, t.screen)
			 end
			 sharetags.tag_move(t, mouse.screen)
		      end
		      awful.tag.viewonly(tags[i])
		   end),
	 awful.key({ modkey, "Control" }, "#" .. i + 9,
		   function ()
		      local t = tags[i]
		      if t then
			 if t.screen ~= mouse.screen then
			    sharetags.tag_move(t, mouse.screen)
			    if not t.selected then
			       awful.tag.viewtoggle(t)
			    end
			 else
			    awful.tag.viewtoggle(t)
			 end
		      end
		   end),
	 awful.key({ modkey, "Shift" }, "#" .. i + 9,
		   function ()
		      if client.focus and tags[i] then
			 awful.client.movetotag(tags[i])
		      end
		   end),
	 awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
		   function ()
		      if client.focus and tags[i] then
			 awful.client.toggletag(tags[i])
		      end
		   end))
   end
end

awful.tag.setproperty(config.tags.emacs, "mwfact", 0.6) -- emacs
awful.tag.setproperty(config.tags.www, "mwfact", 0.7) -- www

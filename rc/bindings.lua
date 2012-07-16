config.keys = {}
config.mouse = {}
local volume = loadrc("volume", "vbe/volume")
local brightness = loadrc("brightness", "vbe/brightness")
local keydoc = loadrc("keydoc", "vbe/keydoc")
local sharetags = loadrc("sharetags", "vbe/sharetags")

local function screenshot(client)
   if not client then
      client = "root"
   else
      client = client.window
   end
   local path = awful.util.getdir("config") .. "/screenshots/" ..
      "screenshot-" .. os.date("%Y-%m-%d--%H:%M:%S") .. ".png"
   awful.util.spawn("import -window " .. client .. " " .. path, false)
end

-- Pull the first window with urgent flag in the current workspace if
-- not displayed. If displayed, just raise it. If no urgent window,
-- push back the previous urgent window to its original tag
local urgent_undo_stack = {}
local function pull_urgent()
   local cl = awful.client.urgent.get()
   local s = client.focus and client.focus.screen or mouse.screen
   if cl then
      -- So, we have a client.
      if not cl:isvisible() then
	 -- But it is not visible. So we will add it to the current
	 -- tag of the current screen.
	 local t = awful.tag.selected(s)
	 if not t then
	    return awful.client.urgent.jumpto()
	 end
	 -- Before adding the tag to the client, we should ensure it
	 -- is on the same screen.
	 if s ~= cl.screen then
	    sharetags.tag_move(cl:tags()[1], s)
	 end
	 -- Add our tag to the client
	 urgent_undo_stack[#urgent_undo_stack + 1] = { cl, t }
	 awful.client.toggletag(t, cl)
      end

      -- Focus and raise the client
      if s ~= cl.screen then
	 mouse.screen = cl.screen
      end
      client.focus = cl
      cl:raise()
   else
      -- OK, we need to restore the previously pushed window to its
      -- original state.
      while #urgent_undo_stack > 0 do
	 local cl, t = unpack(table.remove(urgent_undo_stack,
					   #urgent_undo_stack))
	 -- We only handle visible clients that are attached to the
	 -- appropriate tag. Otherwise, the client is discarded (and
	 -- won't be restored later).
	 if cl and cl:isvisible() and
	    awful.util.table.hasitem(cl:tags(), t) then
	    awful.client.toggletag(t, cl)
	    return
	 end
      end
   end
end

config.keys.global = awful.util.table.join(
   keydoc.group("Focus"),
   awful.key({ modkey,           }, "j",
	     function ()
		awful.client.focus.byidx( 1)
		if client.focus then client.focus:raise() end
	     end,
	     "Focus next window"),
   awful.key({ modkey,           }, "k",
	     function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	     end,
	     "Focus previous window"),
   awful.key({ modkey,           }, "Tab",
	     function ()
		awful.client.focus.history.previous()
		if client.focus then
		   client.focus:raise()
		end
	     end,
	     "Focus previously focused window"),
   awful.key({ modkey,           }, "u", pull_urgent,
	    "Jump to urgent-flagged window"),
   awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
	     "Jump to next screen"),
   awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),

   keydoc.group("Layout manipulation"),
   awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end,
	     "Increase master-width factor"),
   awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end,
	     "Decrease master-width factor"),
   awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster( 1)      end,
	     "Increase number of masters"),
   awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster(-1)      end,
	     "Decrease number of masters"),
   awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol( 1)         end,
	     "Increase number of columns"),
   awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol(-1)         end,
	     "Decrease number of columns"),
   awful.key({ modkey,           }, "space", function () awful.layout.inc(config.layouts,  1) end,
	     "Next layout"),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(config.layouts, -1) end,
	     "Previous layout"),
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
	     "Swap with next window"),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
	     "Swap with previous window"),

   keydoc.group("Misc"),

   -- Spawn a terminal
   awful.key({ modkey,           }, "Return", function () awful.util.spawn(config.terminal) end,
	     "Spawn a terminal"),

   -- Screenshot
   awful.key({}, "Print", screenshot, "Screenshot"),

   -- Restart awesome
   awful.key({ modkey, "Control" }, "r", awesome.restart, "Restart awesome"),

   -- Multimedia keys
   awful.key({ }, "XF86MonBrightnessUp",   brightness.increase),
   awful.key({ }, "XF86MonBrightnessDown", brightness.decrease),
   awful.key({ }, "XF86AudioRaiseVolume", volume.increase),
   awful.key({ }, "XF86AudioLowerVolume", volume.decrease),
   awful.key({ }, "XF86AudioMute",        volume.toggle),

   -- Help
   awful.key({ modkey, }, "F1", keydoc.display)
)

config.keys.client = awful.util.table.join(
   keydoc.group("Window-specific bindings"),
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end,
	     "Fullscreen"),
   awful.key({ modkey,           }, "x",      function (c) c:kill()                         end,
	     "Close"),
   awful.key({ modkey,           }, "o",      awful.client.movetoscreen, "Move to the other screen"),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle, "Toggle floating"),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
	     "Switch with master window"),
   awful.key({ modkey,           }, "t",      function (c) c:raise()            end,
	     "Raise window"),
   awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky end,
	     "Stick window"),
   awful.key({ modkey,           }, "i",      dbg,
	     "Get client-related information"),
   awful.key({ modkey,           }, "m",
	     function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
	     end,
	     "Maximize"),


   -- Screenshot
   awful.key({ modkey }, "Print", screenshot, "Screenshot")
)

keydoc.group("Misc")

config.mouse.client = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

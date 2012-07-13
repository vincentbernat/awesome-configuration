config.keys = {}
config.mouse = {}

config.keys.global = awful.util.table.join(
   -- Tag navigation
   awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
   awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
   awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
   
   -- Focus
   awful.key({ modkey,           }, "j",
	     function ()
		awful.client.focus.byidx( 1)
		if client.focus then client.focus:raise() end
	     end),
   awful.key({ modkey,           }, "k",
	     function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	     end),
   awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),

   -- Layout manipulation
   awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
   awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
   awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
   awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
   awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
   awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
   awful.key({ modkey,           }, "space", function () awful.layout.inc(config.layouts,  1) end),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(config.layouts, -1) end),
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
   awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
   awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
   awful.key({ modkey,           }, "Tab",
	     function ()
		awful.client.focus.history.previous()
		if client.focus then
		   client.focus:raise()
		end
	     end),

   -- Spawn a terminal
   awful.key({ modkey,           }, "Return", function () awful.util.spawn(config.terminal) end),

   -- Restart awesome
   awful.key({ modkey, "Control" }, "r", awesome.restart),

   -- Multimedia keys
   awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q -c 0 set Master 2dB+", false) end),
   awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q -c 0 set Master 2dB-", false) end),
   awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer -q -c 0 set Master toggle", false) end)
)

config.keys.client = awful.util.table.join(
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ modkey,           }, "x",      function (c) c:kill()                         end),
   awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
   awful.key({ modkey,           }, "m",
	     function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
	     end)
)

config.mouse.client = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

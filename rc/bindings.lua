config.keys = {}
config.mouse = {}
local volume = loadrc("volume", "vbe/volume")
local brightness = loadrc("brightness", "vbe/brightness")
local keydoc = loadrc("keydoc", "vbe/keydoc")

local function client_info()
    local v = ""

    -- object
    local c = client.focus
    v = v .. tostring(c)

    -- geometry
    local cc = c:geometry()
    local signx = (cc.x > 0 and "+") or ""
    local signy = (cc.y > 0 and "+") or ""
    v = v .. " @ " .. cc.width .. 'x' .. cc.height .. signx .. cc.x .. signy .. cc.y .. "\n\n"

    local inf = {
        "name", "icon_name", "type", "class", "role", "instance", "pid",
        "icon_name", "skip_taskbar", "id", "group_window", "leader_id", "machine",
        "screen", "hidden", "minimized", "size_hints_honor", "titlebar", "urgent",
        "focus", "opacity", "ontop", "above", "below", "fullscreen", "transient_for",
	"maximixed_horizontal", "maximixed_vertical", "sticky", "modal", "focusable"
    }

    for i = 1, #inf do
        v = v .. string.format('%2s: <span color="%s">%-20s</span> = <span color="%s">%s</span>\n',
			       i,
			       beautiful.fg_widget_label, inf[i],
			       beautiful.fg_widget_value, tostring(c[inf[i]]))
    end

    naughty.notify{ text = string.format('<span font="Terminus 8">%s</span>', v:sub(1,#v-1)),
		    timeout = 0, margin = 10, screen = c.screen }
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
   awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
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

   -- Spawn a terminal
   keydoc.group("Misc"),
   awful.key({ modkey,           }, "Return", function () awful.util.spawn(config.terminal) end,
	     "Spawn a terminal"),

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
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
	     "Stay on top"),
   awful.key({ modkey,           }, "i",      client_info,
	     "Get client-related information"),
   awful.key({ modkey,           }, "m",
	     function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
	     end,
	     "Maximize")
)

config.mouse.client = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

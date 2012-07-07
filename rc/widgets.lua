-- Widgets

require("vicious")

-- Separator
local separator = widget({ type = "textbox" })
separator.text = ' <span color="' .. beautiful.fg_widget_sep .. '">|</span> '

-- Date
local datewidget = widget({ type = "textbox" })
vicious.register(datewidget, vicious.widgets.date,
		 '<span font="Terminus 8" color="' .. beautiful.fg_widget_clock .. '">%a %d/%m, %H:%M</span>', 61)

-- CPU usage
local cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu,
		 function (widget, args)
		    return string.format('<span font="Terminus 8" color="' .. beautiful.fg_widget_label .. '">CPU: </span>' ..
					 '<span font="Terminus 8" color="' .. beautiful.fg_widget_value .. '">%3d%%</span>',
					 args[1])
		 end, 2)

-- Battery
local batwidget = ""
if config.hostname == "guybrush" then
   batwidget = widget({ type = "textbox" })
   vicious.register(batwidget, vicious.widgets.bat,
		    function (widget, args)
		       local color = beautiful.fg_widget_value
		       local current = args[2]
		       if current < 10 then
			  color = beautiful.fg_widget_value_important
		       end
		       return string.format(
			  '<span font="Terminus 8" color="' .. beautiful.fg_widget_label ..
			     '">Bat: </span>' ..
			     '<span font="Terminus 8" color="' .. color ..
			     '">%s %d%%</span>', args[1], current)
		    end,
		    61, "BAT1")
end

-- Network
local netwidget = widget({ type = "textbox" })
local netgraph = awful.widget.graph()
netgraph:set_width(80):set_height(14)
netgraph:set_stack(true):set_scale(true)
netgraph:set_border_color(beautiful.fg_widget_border)
netgraph:set_stack_colors({ "#FF0000", "#0000FF" })
netgraph:set_background_color("#00000000")
vicious.register(netwidget, vicious.widgets.net,
    function (widget, args)
       -- We sum up/down value for all interfaces
       local up = 0
       local down = 0
       local iface
       for name, value in pairs(args) do
	  iface = name:match("^{(%S+) down_b}$")
	  if iface and iface ~= "lo" then down = down + value end
	  iface = name:match("^{(%S+) up_b}$")
	  if iface and iface ~= "lo" then up = up + value end
       end
       -- Update the graph
       netgraph:add_value(up, 1)
       netgraph:add_value(down, 2)
       -- Format the string representation
       local format = function(val)
	  if val > 500000 then
	     return string.format("%.1f MB", val/1000000.)
	  elseif val > 500 then
	     return string.format("%.1f KB", val/1000.)
	  end
	  return string.format("%d B", val)
       end
       return string.format(
	  '<span font="Terminus 8" color="' .. beautiful.fg_widget_label ..
	     '">Up/Down: </span><span font="Terminus 8" color="' .. beautiful.fg_widget_value ..
	     '">%08s</span><span font="Terminus 8" color="' .. beautiful.fg_widget_label ..
	     '">/</span><span font="Terminus 8" color="' .. beautiful.fg_widget_value ..
	     '">%08s</span> ', format(up), format(down))
    end, 3)

-- Memory usage
local memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem,
		 '<span font="Terminus 8" color="' .. beautiful.fg_widget_label .. '">Mem: </span>' ..
		    '<span font="Terminus 8" color="' .. beautiful.fg_widget_value .. '">$1%</span>',
		 13)

-- Volume level
local volwidget = widget({ type = "textbox" })
vicious.register(volwidget, vicious.widgets.volume,
		 '<span font="Terminus 8" color="' .. beautiful.fg_widget_value .. '">$2 $1%</span>',
		2, "Master")
volwidget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () awful.util.spawn("pavucontrol", false) end),
   awful.button({ }, 4, function () awful.util.spawn("amixer -q -c 0 set Master 2dB+", false) end),
   awful.button({ }, 5, function () awful.util.spawn("amixer -q -c 0 set Master 2dB-", false) end)
))

-- File systems
local fs = { ["/"] = "root",
	     ["/home"] = "home",
	     ["/var"] = "var",
	     ["/usr"] = "usr",
	     ["/tmp"] = "tmp",
	     ["/var/cache/build"] = "pbuilder" }
local fswidget = widget({ type = "textbox" })
vicious.register(fswidget, vicious.widgets.fs,
		 function (widget, args)
		    local result = ""
		    for path, name in pairs(fs) do
		       local used = args["{" .. path .. " used_p}"]
		       local color = beautiful.fg_widget_value
		       if used then
			  if used > 90 then
			     color = beautiful.fg_widget_value_important
			  end
			  result = string.format(
			     '%s%s<span font="Terminus 8" color="' .. beautiful.fg_widget_label .. '">%s: </span>' ..
				'<span font="Terminus 8" color="' .. color .. '">%2d%%</span>',
			     result, #result > 0 and separator.text or "", name, used)
		       end
		    end
		    return result
		 end, 10)

local systray = widget({ type = "systray" })

-- Wibox initialisation
local wibox     = {}
local promptbox = {}
local layoutbox = {}

local taglist = {}
taglist.buttons = awful.util.table.join(
   awful.button({ },        1,
		function(t)
		   if t.screen ~= mouse.screen then
		      sharetags.tag_move(t, mouse.screen)
		   end
		   awful.tag.viewonly(t)
		end),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({ },        3,
		function(t)
		   if t.screen ~= mouse.screen then
		      sharetags.tag_move(t, mouse.screen)
		   end
		   awful.tag.viewtoggle(t)
		end),
   awful.button({ modkey }, 3, awful.client.toggletag),
   awful.button({ },        4, awful.tag.viewnext),
   awful.button({ },        5, awful.tag.viewprev))

local tasklist = {}
tasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
		   if c == client.focus then
		      c.minimized = true
		   else
		      if not c:isvisible() then
			 awful.tag.viewonly(c:tags()[1])
		      end
		      -- This will also un-minimize
		      -- the client, if needed
		      client.focus = c
		      c:raise()
		   end
			end))

for s = 1, screen.count() do
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    layoutbox[s] = awful.widget.layoutbox(s)
    if screen.count() > 1 then
       tasklist[s]  = awful.widget.tasklist(
	  function(c)
	     return awful.widget.tasklist.label.currenttags(c, s)
	  end, tasklist.buttons)
    else
       tasklist[s] = ""
    end
    
    -- Create the taglist
    taglist[s]   = sharetags.taglist(s, sharetags.label.all, taglist.buttons)
    -- Create the wibox
    wibox[s] = awful.wibox({ screen = s,
			     fg = beautiful.fg_normal,
			     bg = beautiful.bg_widget,
			     position = "top",
			     height = 14,
    })
    -- Add widgets to the wibox
    local on = function(n, what)
       if s == n or n > screen.count() then return what end
       return ""
    end

    wibox[s].widgets = {
        {
	   taglist[s], layoutbox[s],
	   separator, promptbox[s],
	   layout = awful.widget.layout.horizontal.leftright
	},
	on(1, systray), on(1, separator),
	datewidget, separator,
	on(2, volwidget), on(2, separator),
	on(2, batwidget), on(2, batwidget ~= "" and separator or ""),
	on(2, fswidget), on(2, separator),
	on(1, memwidget), on(1, separator),
	on(1, cpuwidget), on(1, separator),
	on(1, netgraph.widget), on(1, netwidget), on(1, separator),
	tasklist[s], tasklist[s] ~= "" and separator or "",
	layout = awful.widget.layout.horizontal.rightleft }
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "r", function () promptbox[mouse.screen]:run() end))

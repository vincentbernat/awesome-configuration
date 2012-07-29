-- Widgets

require("vicious")
local icons = loadrc("icons", "vbe/icons")

-- Separators
local sepopen = widget({ type = "imagebox" })
sepopen.image = image(awful.util.getdir("config") .. "/icons/widgets/left.png")
local sepclose = widget({ type = "imagebox" })
sepclose.image = image(awful.util.getdir("config") .. "/icons/widgets/right.png")
local spacer = widget({ type = "imagebox" })
spacer.image = image(awful.util.getdir("config") .. "/icons/widgets/spacer.png")

-- Date
local datewidget = widget({ type = "textbox" })
local dateformat = "%H:%M"
if screen.count() > 1 then dateformat = "%a %d/%m, " .. dateformat end
vicious.register(datewidget, vicious.widgets.date,
		 '<span color="' .. beautiful.fg_widget_clock .. '">' ..
		    dateformat .. '</span>', 61)
local dateicon = widget({ type = "imagebox" })
dateicon.image = image(awful.util.getdir("config") .. "/icons/widgets/clock.png")
local cal = (
   function()
      local calendar = nil
      local offset = 0

      local remove_calendar = function()
	 if calendar ~= nil then
	    naughty.destroy(calendar)
	    calendar = nil
	    offset = 0
	 end
      end

      local add_calendar = function(inc_offset)
	 local save_offset = offset
	 remove_calendar()
	 offset = save_offset + inc_offset
	 local datespec = os.date("*t")
	 datespec = datespec.year * 12 + datespec.month - 1 + offset
	 datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
	 local cal = awful.util.pread("ncal -w -m " .. datespec)
	 -- Highlight the current date and month
	 cal = cal:gsub("_.(%d)",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget_clock))
	 cal = cal:gsub("^( +[^ ]+ [0-9]+) *",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget_clock))
	 -- Turn anything other than days in labels
	 cal = cal:gsub("(\n[^%d]+)",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget_label))
	 cal = cal:gsub("([%d ]+)\n?$",
			string.format('<span color="%s">%%1</span>',
				      beautiful.fg_widget_label))
	 calendar = naughty.notify(
	    {
	       text = string.format('<span font="%s">%s</span>',
				    "Terminus 8",
				    cal:gsub(" +\n","\n")),
	       timeout = 0, hover_timeout = 0.5,
	       width = 160,
	    })
      end

      return { add = add_calendar,
	       rem = remove_calendar }
   end)()

datewidget:add_signal("mouse::enter", function() cal.add(0) end)
datewidget:add_signal("mouse::leave", cal.rem)
datewidget:buttons(awful.util.table.join(
		      awful.button({ }, 3, function() cal.add(-1) end),
		      awful.button({ }, 1, function() cal.add(1) end)))

-- CPU usage
local cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu,
		 function (widget, args)
		    return string.format('<span color="' .. beautiful.fg_widget_value .. '">%2d%%</span>',
					 args[1])
		 end, 7)
local cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(awful.util.getdir("config") .. "/icons/widgets/cpu.png")

-- Battery
local batwidget = { widget = "" }
if config.hostname == "guybrush" then
   batwidget.widget = widget({ type = "textbox" })
   vicious.register(batwidget.widget, vicious.widgets.bat,
		    function (widget, args)
		       local color = beautiful.fg_widget_value
		       local current = args[2]
		       if current < 10 and args[1] == "-" then
			  color = beautiful.fg_widget_value_important
			  -- Maybe we want to display a small warning?
			  if current ~= batwidget.lastwarn then
			     batwidget.lastid = naughty.notify(
				{ title = "Battery low!",
				  preset = naughty.config.presets.critical,
				  timeout = 20,
				  text = "Battery level is currently " ..
				     current .. "%.\n" .. args[3] ..
				     " left before running out of power.",
				  icon = icons.lookup({name = "battery-caution",
						       type = "status"}),
				  replaces_id = batwidget.lastid }).id
			     batwidget.lastwarn = current
			  end
		       end
		       return string.format('<span color="' .. color ..
			     '">%s%d%%</span>', args[1], current)
		    end,
		    59, "BAT1")
end
local baticon = widget({ type = "imagebox" })
baticon.image = image(awful.util.getdir("config") .. "/icons/widgets/bat.png")

-- Network
local netup   = widget({ type = "textbox" })
local netdown = widget({ type = "textbox" })
local netupicon = widget({ type = "imagebox" })
netupicon.image = image(awful.util.getdir("config") .. "/icons/widgets/up.png")
local netdownicon = widget({ type = "imagebox" })
netdownicon.image = image(awful.util.getdir("config") .. "/icons/widgets/down.png")

local netgraph = awful.widget.graph()
netgraph:set_width(80):set_height(16)
netgraph:set_stack(true):set_scale(true)
netgraph:set_border_color(beautiful.fg_widget_border)
netgraph:set_stack_colors({ "#EF8171", "#cfefb3" })
netgraph:set_background_color("#00000033")
vicious.register(netup, vicious.widgets.net,
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
       -- Down
       netdown.text = string.format('<span color="' .. beautiful.fg_widget_value ..
				    '">%08s</span>', format(down))
       -- Up
       return string.format('<span color="' .. beautiful.fg_widget_value ..
			    '">%08s</span>', format(up))
    end, 3)

-- Memory usage
local memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem,
		 '<span color="' .. beautiful.fg_widget_value .. '">$1%</span>',
		 19)
local memicon = widget({ type = "imagebox" })
memicon.image = image(awful.util.getdir("config") .. "/icons/widgets/mem.png")

-- Volume level
local volicon = widget({ type = "imagebox" })
volicon.image = image(awful.util.getdir("config") .. "/icons/widgets/vol.png")
local volwidget = widget({ type = "textbox" })
vicious.register(volwidget, vicious.widgets.volume,
		 '<span color="' .. beautiful.fg_widget_value .. '">$2 $1%</span>',
		17, "Master")
volume = loadrc("volume", "vbe/volume")
volwidget:buttons(awful.util.table.join(
		     awful.button({ }, 1, volume.mixer),
		     awful.button({ }, 3, volume.toggle),
		     awful.button({ }, 4, volume.increase),
		     awful.button({ }, 5, volume.decrease)))

-- File systems
local fs = { ["/"] = "root",
	     ["/home"] = "home",
	     ["/var"] = "var",
	     ["/usr"] = "usr",
	     ["/tmp"] = "tmp",
	     ["/var/cache/build"] = "pbuilder" }
local fsicon = widget({ type = "imagebox" })
fsicon.image = image(awful.util.getdir("config") .. "/icons/widgets/disk.png")
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
			     '%s%s<span color="' .. beautiful.fg_widget_label .. '">%s: </span>' ..
				'<span color="' .. color .. '">%2d%%</span>',
			     result, #result > 0 and " " or "", name, used)
		       end
		    end
		    return result
		 end, 53)

local systray = widget({ type = "systray" })

-- Wibox initialisation
local wibox     = {}
local promptbox = {}
local layoutbox = {}

local taglist = {}
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
    tasklist[s]  = awful.widget.tasklist(
       function(c)
	  local title, color, _, icon = awful.widget.tasklist.label.currenttags(c, s)
	  return title, color, nil, icon
       end, tasklist.buttons)

    -- Create the taglist
    taglist[s]   = sharetags.taglist(s, sharetags.label.all)
    -- Create the wibox
    wibox[s] = awful.wibox({ screen = s,
			     fg = beautiful.fg_normal,
			     bg = beautiful.bg_widget,
			     position = "top",
			     height = 16,
    })
    -- Add widgets to the wibox
    local on = function(n, what)
       if s == n or n > screen.count() then return what end
       return ""
    end

    wibox[s].widgets = {
        {
	   screen.count() > 1 and sepopen or "",
	   taglist[s],
	   screen.count() > 1 and spacer or "",
	   layoutbox[s],
	   screen.count() > 1 and sepclose or "",
	   promptbox[s],
	   layout = awful.widget.layout.horizontal.leftright
	},
	on(1, systray),
	sepclose, datewidget, screen.count() > 1 and dateicon or "", spacer,
	on(2, volwidget), on(2, volicon), on(2, spacer),

	on(2, batwidget.widget),
	on(2, batwidget.widget ~= "" and screen.count() > 1 and baticon or ""),
	on(2, batwidget.widget ~= "" and spacer or ""),

	on(2, fswidget), screen.count() > 1 and on(2, fsicon) or "",
	screen.count() > 1 and on(2, sepopen) or on(2, spacer),

	screen.count() > 1 and on(1, netgraph.widget) or "",
	on(1, netdownicon), on(1, netdown),
	on(1, netupicon), on(1, netup), on(1, spacer),

	on(1, memwidget), on(1, memicon), on(1, spacer),
	on(1, cpuwidget), on(1, cpuicon), on(1, sepopen),
	tasklist[s],
	layout = awful.widget.layout.horizontal.rightleft }
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "r", function () promptbox[mouse.screen]:run() end,
	     "Prompt for a command"))

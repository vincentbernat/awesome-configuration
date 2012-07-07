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
local batwidget = nil
if config.hostname == "guybrush" then
   batwidget = widget({ type = "textbox" })
   vicious.register(batwidget, vicious.widgets.bat,
		    '<span font="Terminus 8" color="' .. beautiful.fg_widget_label .. '">BAT: </span>' ..
		       '<span font="Terminus 8" color="' .. beautiful.fg_widget_value .. '">$1 $2%</span>',
		    61, "BAT0")
end

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
    tasklist[s]  = awful.widget.tasklist(
       function(c)
	  return awful.widget.tasklist.label.currenttags(c, s)
       end, tasklist.buttons)
    
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
    local onfirst = function(what)
       if s == 1 then return what end
       return nil
    end
    local onsecond = function(what)
       if s == 2 or screen.count() == 1 then return what end
       return nil
    end

    wibox[s].widgets = {
        {
	   taglist[s], layoutbox[s],
	   separator, promptbox[s],
	   layout = awful.widget.layout.horizontal.leftright
	},
	onfirst(systray), onfirst(separator),
	datewidget, separator,
	onsecond(volwidget), onsecond(separator),
	onsecond(batwidget), onsecond(batwidget and separator or nil),
	onfirst(memwidget), onfirst(separator),
	onfirst(cpuwidget), onfirst(separator),
	tasklist[s], separator,
	layout = awful.widget.layout.horizontal.rightleft }
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "r", function () promptbox[mouse.screen]:run() end))

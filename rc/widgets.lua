-- Widgets
vicious = require("vicious")
wibox = require("wibox")
gears = require("gears")
local icons = loadrc("icons", "vbe/icons")

-- Separators
local sepopen = wibox.widget.imagebox()
sepopen:set_image(beautiful.icons .. "/widgets/left.png")
local sepclose = wibox.widget.imagebox()
sepclose:set_image(beautiful.icons .. "/widgets/right.png")
local spacer = wibox.widget.imagebox()
spacer:set_image(beautiful.icons .. "/widgets/spacer.png")
local e_widget = wibox.widget.base.empty_widget()

-- Date
local datewidget = wibox.widget.textbox()
local dateformat = "%H:%M"
if screen.count() > 1 then dateformat = "%a %d/%m, " .. dateformat end
vicious.register(datewidget, vicious.widgets.date,
         '<span color="' .. beautiful.fg_widget_clock .. '">' ..
            dateformat .. '</span>', 10)
local dateicon = wibox.widget.imagebox()
dateicon:set_image(beautiful.icons .. "/widgets/clock.png")
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
     cal = cal:gsub("_.([%d ])",
            string.format('<span color="%s">%%1</span>',
                      beautiful.fg_widget_clock))
     cal = cal:gsub("^( +[^ ]+ [0-9]+) *",
            string.format('<span color="%s">%%1</span>',
                      beautiful.fg_widget_clock))
     -- Turn anything other than days in labels
     cal = cal:gsub("(\n[^%d ]+)",
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
           screen = mouse.screen,
        })
      end

      return { add = add_calendar,
           rem = remove_calendar }
   end)()

datewidget:connect_signal("mouse::enter", function() cal.add(0) end)
datewidget:connect_signal("mouse::leave", cal.rem)
datewidget:buttons(awful.util.table.join(
              awful.button({ }, 3, function() cal.add(-1) end),
              awful.button({ }, 1, function() cal.add(1) end)))

-- CPU usage
local cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu,
         function (widget, args)
            return string.format('<span color="' .. beautiful.fg_widget_value .. '">%2d%%</span>',
                     args[1])
         end, 1)
local cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.icons .. "/widgets/cpu.png")

-- CPU temp
local thermalwidget  = wibox.widget.textbox()

-- Register
vicious.register(thermalwidget, vicious.widgets.thermal, " <span color='yellow'>@</span> <span color='" .. beautiful.fg_widget_value .. "'>$1°C</span>", 1, { "coretemp.0/hwmon/hwmon1", "core"} )

-- Battery widget
batwidget = wibox.widget.textbox()
-- Register
vicious.register(batwidget, vicious.widgets.bat, function(widget, args)
var="% (".. args[3] ..")</span>"
if args[2] >= 75 then
var = "<span color='cyan'>" .. args[2] .. var
elseif args[2] >= 50 then
var = "<span color='yellow'>" .. args[2] .. var
elseif args[2] >= 25 then
var = "<span color='orange'>" .. args[2] .. var
else
var = "<span color='red'>Warning : " .. args[2] .. var
end
return var
end, 10, "BAT0")
--vicious.register(batwidget, widgets.bat, "<span color='cyan'>$2%</span> <span color='yellow'>($3)</span> <span color='green'>$1</span> <span color='orange'>|</span> ", 5, "BAT0")

-- Battery usage
local baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.icons .. "/widgets/bat.png")

-- Network
local netup   = wibox.widget.textbox()
local netdown = wibox.widget.textbox()
local netupicon = wibox.widget.imagebox()
netupicon:set_image(beautiful.icons .. "/widgets/up.png")
local netdownicon = wibox.widget.imagebox()
netdownicon:set_image(beautiful.icons .. "/widgets/down.png")

local netgraph = awful.widget.graph()
netgraph:set_width(80):set_height(16 * theme.scale)
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
    end, 1)
vicious.register(netdown, vicious.widgets.net, function (widgets, args)
        return netdown.text
    end, 1)

-- Memory usage
-- Initialize widget
memwidget = wibox.widget.textbox()
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, function(widget, args)
var="%</span>"
if args[1] >= 75 then
var = "<span color='red'>Warning : " .. args[1] .. var
elseif args[1] >= 50 then
var = "<span color='orange'>" .. args[1] .. var
elseif args[1] >= 25 then
var = "<span color='yellow'>" .. args[1] .. var
else
var = "<span color='cyan'>" .. args[1] .. var
end
return var
end, 3)
local memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.icons .. "/widgets/mem.png")

-- Volume level
local volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.icons .. "/widgets/vol.png")
local volwidget = wibox.widget.textbox()
vicious.register(volwidget, vicious.widgets.volume,
         '<span color="' .. beautiful.fg_widget_value .. '">$2 $1%</span>',
        1, "Master")
volume = loadrc("volume", "vbe/volume")
volwidget:buttons(awful.util.table.join(
             awful.button({ }, 1, volume.mixer),
             awful.button({ }, 3, volume.toggle),
             awful.button({ }, 4, volume.increase),
             awful.button({ }, 5, volume.decrease)))

-- File systems
local fs = { "/",
         "/home",
         "/boot",
             "/var/lib/systems" }
local fsicon = wibox.widget.imagebox()
fsicon:set_image(beautiful.icons .. "/widgets/disk.png")
local fswidget = wibox.widget.textbox()
vicious.register(fswidget, vicious.widgets.fs,
         function (widget, args)
            local result = ""
            for _, path in pairs(fs) do
               local used = args["{" .. path .. " used_p}"]
               local color = beautiful.fg_widget_value
               if used then
              if used > 90 then
                 color = beautiful.fg_widget_value_important
              end
                          local name = string.gsub(path, "[%w/]*/(%w+)", "%1")
                          if name == "/" then name = "root" end
              result = string.format(
                 '%s%s<span color="' .. beautiful.fg_widget_label .. '">%s: </span>' ..
                '<span color="' .. color .. '">%2d%%</span>',
                 result, #result > 0 and " " or "", name, used)
               end
            end
            return result
         end, 60, "-lx fuse -x aufs")

local systray = wibox.widget.systray()

-- Wibox initialisation
local mywibox     = {}
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
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    promptbox[s] = awful.widget.prompt()
    layoutbox[s] = awful.widget.layoutbox(s)
    tasklist[s]  = awful.widget.tasklist(s, function(c)
      local title, color, _, icon = awful.widget.tasklist.filter.currenttags(c, s)
      return title, color, nil, icon
       end, tasklist.buttons)

    -- Create the taglist
    taglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.filter.all, taglist.buttons)
    -- Create the wibox
    mywibox[s] = awful.wibox({ screen = s,
                 fg = beautiful.fg_normal,
                 bg = beautiful.bg_widget,
                 position = "top",
                 height = 16 * theme.scale,
    })

    -- Add widgets to the wibox
    local on = function(n, what)
       if s == n or n > screen.count() then return what end
       return e_widget
    end

    local left_layout = wibox.layout.fixed.horizontal()
    if screen.count() > 1 then left_layout:add(sepopen) end
    left_layout:add(layoutbox[s])
    if screen.count() > 1 then left_layout:add(spacer) end
    left_layout:add(taglist[s])
    if screen.count() > 1 then left_layout:add(sepclose) end
    left_layout:add(promptbox[s])

    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(on(1, sepopen))
    right_layout:add(on(1, thermalwidget))
    right_layout:add(on(1, spacer))
    right_layout:add(on(1, cpuicon))
    right_layout:add(on(1, cpuwidget))
    right_layout:add(on(1, spacer))
    right_layout:add(on(1, memicon))
    right_layout:add(on(1, memwidget))
    right_layout:add(on(1, spacer))
    right_layout:add(on(1, netdownicon))
    right_layout:add(on(1, netdown))
    right_layout:add(on(1, netupicon))
    right_layout:add(on(1, netup))
    if screen.count() > 1 then
        right_layout:add(on(1, netgraph.widget))
        right_layout:add(on(2, sepopen))
        right_layout:add(on(2, fsicon))
        right_layout:add(on(2, fswidget))
    end

    if batwidget ~= "" then
        right_layout:add(on(2, spacer))
        right_layout:add(on(2, baticon))
        right_layout:add(on(2, batwidget))
    end
    right_layout:add(on(2, spacer))
    right_layout:add(on(2, volwidget))

    if screen.count() > 1 then
        right_layout:add(on(2, volicon))
    end

    right_layout:add(on(2, spacer))
    right_layout:add(datewidget)
    if screen.count() > 1 then
        right_layout:add(dateicon)
    end
    right_layout:add(sepclose)
    right_layout:add(on(1, systray))

    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(tasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "r", function () promptbox[mouse.screen]:run() end,
         "Prompt for a command"))

config.taglist = taglist

-- Initialize widget
memwidget = wibox.widget.textbox()
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, function(widget, args)
var="%</span> <span color='yellow'>(".. args[2] .."/".. args[3] ..")</span> <span color='orange'>|</span> "
if args[1] >= 75 then
var = "<span color='red'>Warning : " .. args[1] .. var
elseif args[1] >= 50 then
var = "<span color='orange'>" .. args[1] .. var
elseif args[1] >= 25 then
var = "<span color='yellow'>" .. args[1] .. var
else
var = "<span color='cyan'>" .. args[1] .. var
end
return var
end, 5)


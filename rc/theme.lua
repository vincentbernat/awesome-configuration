-- Small modifications to anrxc's zenburn theme

local na = awful.util.color_strip_alpha
local icons = awful.util.getdir("config") .. "/icons"

local function scale()
   local xrdb = io.popen("xrdb -query")
   if xrdb then
      for line in xrdb:lines() do
	 output = line:match("^Xft.dpi:\t(%d+)$")
	 if output then
            xrdb:close()
	    return tonumber(output)/96
	 end
      end
      xrdb:close()
   end
   return 1
end

theme = {}
theme.scale = scale()
theme.icons = icons
theme.wallpaper_cmd = { "/bin/true" }
theme.font = "Terminus " .. 9 * theme.scale
theme.tasklist_font = "DejaVu Sans " .. 8 * theme.scale

theme.bg_normal     = "#22222299"
theme.bg_focus      = "#d8d8d8bb"
theme.bg_urgent     = "#d02e5499"
theme.bg_minimize   = "#44444499"

theme.fg_normal     = "#cccccc"
theme.fg_focus      = "#000000"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = 4
theme.border_normal = "#00000000"
theme.border_focus  = "#FF7F00"
theme.border_marked = "#91231c66"

-- Widget stuff
theme.bg_widget        = "#000000BB"
theme.fg_widget_label  = "#737d8c"
theme.fg_widget_value  = na(theme.fg_normal)
theme.fg_widget_value_important  = "#E80F28"
theme.fg_widget_border = theme.fg_widget_label
theme.fg_widget_clock  = na(theme.border_focus)

-- Taglist
theme.taglist_squares_sel   = icons .. "/taglist/squarefw.png"
theme.taglist_squares_unsel = icons .. "/taglist/squarew.png"

-- Layout icons
for _, l in pairs(config.layouts) do
   theme["layout_" .. l.name] = icons .. "/layouts/" .. l.name .. ".png"
end

-- Naughty
naughty.config.presets.normal.bg = "#111111"
for _, preset in pairs({"normal", "low", "critical"}) do
   naughty.config.presets[preset].font = "DejaVu Sans " .. 10 * theme.scale
   naughty.config.presets[preset].margin = 12 * theme.scale
   naughty.config.presets[preset].border_width = 3 * theme.scale
end
naughty.config.notify_callback = function(args)
   args.icon = nil
   return args
end

return theme

-- Small modifications to anrxc's zenburn theme

local na = awful.util.color_strip_alpha
local theme = loadrc("../themes/nice-and-clean-theme/theme")
if theme then
   theme.wallpaper_cmd = { "/bin/true" }
   theme.font = "Terminus 8"

   for n, l in pairs(theme) do
      local layout = n:match("layout_([%w]+)")
      if layout then
	 theme[n] = awful.util.getdir("config") .. "/icons/layouts/" .. layout .. ".png"
      end
   end

   theme.border_width  = 4
   theme.border_normal = "#00000000"
   theme.border_focus  = "#FF7F0066"
   theme.border_marked = theme.border_marked .. "66"

   theme.bg_normal        = theme.bg_normal .. "99"
   theme.bg_focus         = theme.bg_focus .. "BB"
   theme.bg_urgent        = theme.bg_urgent .. "99"
   theme.bg_minimize      = theme.bg_minimize .. "99"

   -- Widget stuff
   theme.bg_widget        = "#000000BB"
   theme.fg_widget_label  = "#737d8c"
   theme.fg_widget_value  = na(theme.fg_normal)
   theme.fg_widget_value_important  = "#E80F28"
   theme.fg_widget_border = theme.fg_widget_label
   theme.fg_widget_clock  = na(theme.border_focus)

   -- Naughty
   naughty.config.presets.normal.bg = theme.bg_widget
   naughty.config.default_preset.font = "DejaVu Sans 10"

   return theme
end

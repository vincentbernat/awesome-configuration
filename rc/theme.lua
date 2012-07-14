-- Small modifications to anrxc's zenburn theme

local na = awful.util.color_strip_alpha
local theme = loadrc("../themes/nice-and-clean-theme/theme")
if theme then
   theme.wallpaper_cmd = { "/bin/true" }
   theme.font = "DejaVu Sans 9"

   theme.border_width  = 4
   theme.border_normal = "#00000000"
   theme.border_focus  = "#FF7F0066"
   theme.border_marked = theme.border_marked .. "66"

   theme.bg_normal        = theme.bg_normal .. "99"
   theme.bg_focus         = theme.bg_focus .. "99"
   theme.bg_urgent        = theme.bg_urgent .. "99"
   theme.bg_minimize      = theme.bg_minimize .. "99"

   -- Widget stuff
   theme.bg_widget        = "#00000099"
   theme.fg_widget_label  = "#737d8c"
   theme.fg_widget_value  = na(theme.fg_normal)
   theme.fg_widget_value_important  = na(theme.border_marked)
   theme.fg_widget_sep    = na(theme.fg_normal)
   theme.fg_widget_border = theme.fg_widget_label
   theme.fg_widget_clock  = na(theme.border_focus)
   theme.fg_widget_end    = "#FFFFFF"
   theme.fg_widget_center = "#FFCCCC"
   theme.fg_widget_start  = "#FF0000"

   return theme
end

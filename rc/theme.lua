-- Small modifications to anrxc's zenburn theme

local theme = loadrc("../themes/nice-and-clean-theme/theme")
if theme then
   theme.wallpaper_cmd = { "/bin/true" }
   theme.font = "DejaVu Sans 9"
   theme.border_width = 2
   theme.border_normal = "#00000000"
   theme.border_focus = theme.border_focus .. "66"
   theme.border_marked = theme.border_marked .. "66"

   theme.bg_normal        = theme.bg_normal .. "99"
   theme.bg_focus         = theme.bg_focus .. "99"
   theme.bg_urgent        = theme.bg_urgent .. "99"
   theme.bg_minimize      = theme.bg_minimize .. "99"
   theme.bg_widget        = "#00000099"
   theme.fg_widget_label  = "#708090"
   theme.fg_widget_value  = "#FFFFFF"
   theme.fg_widget_value_important  = "#FF2222"
   theme.fg_widget_sep    = "#FFFFFF"
   theme.fg_widget_border = "#FFFFFF"
   theme.fg_widget_clock  = "#FF7F00"
   theme.fg_widget_end    = "#FFFFFF"
   theme.fg_widget_center = "#FFCCCC"
   theme.fg_widget_start  = "#FF0000"
   return theme
end

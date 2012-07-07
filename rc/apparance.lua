-- Theme
beautiful.init(awful.util.getdir("config") .. "/rc/theme.lua")

-- GTK stuff: we choose Adwaita theme which seems to be the only one
-- kept up-to-date with GTK2 and GTK3...

-- Also see: http://developer.gnome.org/gtk3/3.2/GtkSettings.html
local gtk = 'gtk-font-name="' .. beautiful.font .. '"' .. [[

gtk-theme-name="Adwaita"
gtk-icon-theme-name="gnome-wine"
gtk-cursor-theme-name="oxy-cherry"
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
gtk-xft-rgba="rgb"
gtk-key-theme-name="Emacs"
]]

local gtk2 = io.open(os.getenv("HOME") .. "/.gtkrc-2.0", "w")
gtk2:write(gtk)
gtk2:close()

-- GTK3 is the same, but no double quotes for strings
local gtk3 = io.open(os.getenv("HOME") .. "/.config/gtk-3.0/settings.ini", "w")
gtk, _ = gtk:gsub('"', '')
gtk3:write("[Settings]\n")
gtk3:write(gtk)
gtk3:close()

-- For QT, the configuration file is ~/.config/Trolltech.conf. It
-- seems a bit complex to override it each time. The solution is to
-- run qtconfig and to select "GTK+" for the style and the appropriate
-- font.

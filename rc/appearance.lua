-- Theme
beautiful.init(awful.util.getdir("config") .. "/rc/theme.lua")

-- GTK stuff: we choose Adwaita theme which seems to be the only one
-- kept up-to-date with GTK2 and GTK3...

-- Also see: http://developer.gnome.org/gtk3/3.2/GtkSettings.html
local gtk = [[
gtk-font-name="DejaVu Sans 9"
gtk-theme-name="Adwaita"
gtk-icon-theme-name="gnome-wine"
gtk-fallback-icon-theme="gnome"
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
os.execute("test -d ~/.config/gtk-3.0 || mkdir -p ~/.config/gtk-3.0")
local gtk3 = io.open(os.getenv("HOME") .. "/.config/gtk-3.0/settings.ini", "w")
gtk, _ = gtk:gsub('"', '')
gtk3:write("[Settings]\n")
gtk3:write(gtk)
gtk3:close()

-- For QT, the configuration file is ~/.config/Trolltech.conf. It
-- seems a bit complex to override it each time. The solution is to
-- run qtconfig and to select "GTK+" for the style and the appropriate
-- font.

-- The systray is a bit complex. We need to configure it to display
-- the right colors. Here is a link with more background about this:
--  http://thread.gmane.org/gmane.comp.window-managers.awesome/9028
xprop = assert(io.popen("xprop -root _NET_SUPPORTING_WM_CHECK"))
wid = xprop:read():match("^_NET_SUPPORTING_WM_CHECK.WINDOW.: window id # (0x[%S]+)$")
xprop:close()
if wid then
   wid = tonumber(wid) + 1
   os.execute("xprop -id " .. wid .. " -format _NET_SYSTEM_TRAY_COLORS 32c " ..
	      "-set _NET_SYSTEM_TRAY_COLORS " ..
	      "65535,65535,65535,65535,8670,8670,65535,32385,0,8670,65535,8670")
end

-- Set cursor theme
os.execute("xsetroot -cursor_name left_ptr")

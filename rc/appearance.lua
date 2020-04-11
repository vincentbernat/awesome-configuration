-- Theme
beautiful.init(awful.util.getdir("config") .. "/rc/theme.lua")

-- Also have a look at `xsettingsd` which is used for GTK 3. At some
-- point, when we don't need GTK 2, we can use only xsettingsd and
-- avoid duplication.
local gtk2 = io.open(os.getenv("HOME") .. "/.gtkrc-2.0", "w")
gtk2:write([[
gtk-theme-name="Adwaita"
gtk-icon-theme-name="Adwaita"
gtk-cursor-theme-name="Adwaita"
gtk-cursor-theme-size=0
gtk-font-name="DejaVu Sans 10"
gtk-button-images=1
gtk-menu-images=1
gtk-fallback-icon-theme="gnome"
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-decoration-layout=":menu"
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintslight"
gtk-xft-rgba="rgb"

gtk-key-theme-name="Emacs"
binding "vbe-text-entry-bindings" {
  unbind "<ctrl>b"
  unbind "<shift><ctrl>b"
  unbind "<ctrl>f"
  unbind "<shift><ctrl>f"
  unbind "<ctrl>w"
  bind "<alt>BackSpace" { "delete-from-cursor" (word-ends, -1) }
}
class "GtkEntry" binding "vbe-text-entry-bindings"
class "GtkTextView" binding "vbe-text-entry-bindings"
]])
gtk2:close()

os.execute("test -d ~/.config/gtk-3.0 || mkdir -p ~/.config/gtk-3.0")
os.execute("rm -f ~/.config/gtk-3.0/settings.ini")
local gtk3 = io.open(os.getenv("HOME") .. "/.config/gtk-3.0/gtk.css", "w")
gtk3:write([[
/* Useless: we cannot override properly by unbinding some keys */
/* @import url("/usr/share/themes/Emacs/gtk-3.0/gtk-keys.css"); */

@binding-set custom-text-entry
{
  bind "<alt>b" { "move-cursor" (words, -1, 0) };
  bind "<shift><alt>b" { "move-cursor" (words, -1, 1) };
  bind "<alt>f" { "move-cursor" (words, 1, 0) };
  bind "<shift><alt>f" { "move-cursor" (words, 1, 1) };

  bind "<ctrl>a" { "move-cursor" (paragraph-ends, -1, 0) };
  bind "<shift><ctrl>a" { "move-cursor" (paragraph-ends, -1, 1) };
  bind "<ctrl>e" { "move-cursor" (paragraph-ends, 1, 0) };
  bind "<shift><ctrl>e" { "move-cursor" (paragraph-ends, 1, 1) };

  bind "<ctrl>y" { "paste-clipboard" () };

  bind "<ctrl>d" { "delete-from-cursor" (chars, 1) };
  bind "<alt>d" { "delete-from-cursor" (word-ends, 1) };
  bind "<ctrl>k" { "delete-from-cursor" (paragraph-ends, 1) };
  bind "<alt>backslash" { "delete-from-cursor" (whitespace, 1) };
  bind "<alt>BackSpace" { "delete-from-cursor" (word-ends, -1) };

  bind "<alt>space" { "delete-from-cursor" (whitespace, 1)
                      "insert-at-cursor" (" ") };
  bind "<alt>KP_Space" { "delete-from-cursor" (whitespace, 1)
                         "insert-at-cursor" (" ")  };
}

entry, textview
{
  -gtk-key-bindings: custom-text-entry;
}

.window-frame, .window-frame:backdrop {
  box-shadow: 0 0 0 black;
  border-style: none;
  margin: 0;
  border-radius: 0;
}

.titlebar {
  border-radius: 0;
}
]])
gtk3:close()

-- For QT, the configuration file is ~/.config/Trolltech.conf. It
-- seems a bit complex to override it each time. The solution is to
-- run qtconfig and to select "GTK+" for the style and the appropriate
-- font. QT uses GTK2. You should ensure that the appropriate engines
-- exist (in both 32 and 64 bits in case of multiarch), notably
-- gtk2-engines-pixbuf.

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

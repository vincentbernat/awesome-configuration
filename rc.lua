require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")

-- Simple function to load additional LUA files from rc/.
function loadrc(name, mod)
   local success
   local result

   -- Which file? In rc/ or in lib/?
   local path = awful.util.getdir("config") .. "/" ..
      (mod and "lib" or "rc") ..
      "/" .. name .. ".lua"

   -- If the module is already loaded, don't load it again
   if mod and package.loaded[mod] then return package.loaded[mod] end

   -- Execute the RC/module file
   success, result = pcall(function() return dofile(path) end)
   if not success then
      naughty.notify({ title = "Error while loading an RC file",
		       text = "When loading `" .. name ..
			  "`, got the following error:\n" .. result,
		       preset = naughty.config.presets.critical
		     })
      return print("E: error loading RC file '" .. name .. "': " .. result)
   end

   -- Is it a module?
   if mod then
      return package.loaded[mod]
   end

   return result
end

loadrc("errors")		-- errors and debug stuff

-- Global configuration
modkey = "Mod4"
config = {}
config.terminal = table.concat(
   { 
      "urxvtcd",
      "++iso14755",		-- Disable ISO 14755 mode
      "+sb",			-- Disable scrollbar
      "-si -sw",		-- Don't scroll to bottom
      "-j",			-- Enable jump scrolling
      "-sl 2000",		-- Scrollback buffer
      "-bc",			-- Blink cursor
      "-cr green",		-- Cursor color
      "-depth 32",
      -- Color stuff
      "-bg rgba:0000/0000/0000/eeee",
      "-fg white",
      -- See: http://xcolors.net/ ; colorful theme
      "--color0  rgb:15/15/15",
      "--color8  rgb:69/69/69",
      "--color1  rgb:FF/8E/AF",
      "--color9  rgb:ED/4C/7A",
      "--color2  rgb:A6/E2/5F",
      "--color10 rgb:A6/E1/79",
      "--color3  rgb:F8/E5/78",
      "--color11 rgb:FF/DF/6B",
      "--color4  rgb:A6/E2/F0",
      "--color12 rgb:79/D2/FF",
      "--color5  rgb:E8/5B/92",
      "--color13 rgb:BB/5D/79",
      "--color6  rgb:5F/86/8F",
      "--color14 rgb:87/A8/AF",
      "--color7  rgb:D5/F1/F2",
      "--color15 rgb:E2/F1/F6",
      "-fn xft:DejaVuSansMono-8",	       -- Font
      "-letsp -1",			       -- Fix font width
   }, " ")
config.layouts = {
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.fair,
   awful.layout.suit.floating,
}
config.tags = { 
   { layout = awful.layout.suit.fair }, -- 1
   { name = "emacs", mwfact = 0.6 },
   { name = "www", mwfact = 0.7 },
   { name = "im" , mwfact = 0.2 },
   { }, -- 5
   { }, -- 6
   { }, -- 7
}
config.hostname = awful.util.pread('uname -n'):gsub('\n', '')

-- Remaining modules
loadrc("xrun")			-- xrun function
loadrc("appearance")		-- theme and appearance settings
loadrc("debug")			-- debugging primitive `dbg()`

loadrc("start")			-- programs to run on start
loadrc("bindings")		-- keybindings
loadrc("keyboard")		-- keyboard configuration
loadrc("wallpaper")		-- wallpaper settings
loadrc("tags")			-- tags handling
loadrc("widgets")		-- widgets configuration
loadrc("xlock")			-- lock screen
loadrc("signals")		-- window manager behaviour
loadrc("rules")			-- window rules
loadrc("quake")			-- quake console
loadrc("xrandr")		-- xrandr menu

root.keys(config.keys.global)

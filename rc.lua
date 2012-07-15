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
      "-sh 30",			-- Darken the background
      -- Color stuff
      "-bg rgba:0000/0000/0000/dddd",
      "-fg white",
      "--color0 rgb:00/00/00",
      "--color1 rgb:AA/00/00",
      "--color2 rgb:00/AA/00",
      "--color3 rgb:AA/55/00",
      "--color4 rgb:41/69/E1", -- Royal Blue
      "--color5 rgb:AA/00/AA",
      "--color6 rgb:00/AA/AA",
      "--color7 rgb:AA/AA/AA",
      "--color8 rgb:55/55/55",
      "--color9 rgb:FF/55/55",
      "--color10 rgb:55/FF/55",
      "--color11 rgb:FF/FF/55",
      "--color12 rgb:55/55/FF",
      "--color13 rgb:FF/55/FF",
      "--color14 rgb:55/FF/FF",
      "--color15 rgb:FF/FF/FF",
      "-fn xft:DejaVuSansMono-8",	       -- Font
      "-letsp -1",			       -- Fix font width
      "-pe matcher",			       -- Enable "matcher extension" (to detect URL)
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

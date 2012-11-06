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

-- Create cache directory
os.execute("test -d " .. awful.util.getdir("cache") ..
           " || mkdir -p " .. awful.util.getdir("cache"))

-- Global configuration
modkey = "Mod4"
config = {}
config.terminal = "urxvtcd --perl-lib " .. awful.util.getdir("config") .. "/lib/rxvt"
config.layouts = {
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.fair,
   awful.layout.suit.floating,
}
config.hostname = awful.util.pread('uname -n'):gsub('\n', '')
config.browser = "iceweasel"

-- Remaining modules
loadrc("xrun")			-- xrun function
loadrc("appearance")		-- theme and appearance settings
loadrc("debug")			-- debugging primitive `dbg()`

loadrc("start")			-- programs to run on start
loadrc("bindings")		-- keybindings
loadrc("wallpaper")		-- wallpaper settings
loadrc("widgets")		-- widgets configuration
loadrc("tags")			-- tags handling
loadrc("xlock")			-- lock screen
loadrc("signals")		-- window manager behaviour
loadrc("rules")			-- window rules
loadrc("quake")			-- quake console
loadrc("xrandr")		-- xrandr menu

root.keys(config.keys.global)

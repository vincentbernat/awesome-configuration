require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")

-- Simple function to load additional LUA files from rc/.
function loadrc(name)
   local success
   local result
   local path = awful.util.getdir("config") .. "/rc/" .. name .. ".lua"
   success, result = pcall(function() return dofile(path) end)
   if not success then
      naughty.notify({ title = "Error while loading an RC file",
		       text = "When loading `" .. name ..
			  "`, got the following error:\n" .. result,
		       preset = naughty.config.presets.critical
		     })
      return print("E: error loading RC file '" .. name .. "': " .. result)
   end
   return result
end

-- Error handling
loadrc("errors")

-- Global configuration
modkey = "Mod4"
config = {}
config.terminal = table.concat({"urxvtcd",
				"++iso14755 +sb -si -sw -j -fn fixed -sl 2000",
				"-sh 30 -bc -tint white -fg white -depth 32",
				"--color4 RoyalBlue --color12 RoyalBlue",
				"-bg rgba:0000/0000/0000/dddd"},
			       " ")
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
loadrc("start")			-- programs to run on start
loadrc("bindings")		-- keybindings
loadrc("wallpaper")		-- wallpaper settings
loadrc("tags")			-- tags handling
loadrc("widgets")		-- widgets configuration
loadrc("xlock")			-- lock screen
loadrc("signals")		-- window manager behaviour
loadrc("rules")			-- window rules
loadrc("quake")			-- quake console

root.keys(config.keys.global)

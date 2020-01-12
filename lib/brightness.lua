-- Handle brightness (with brightnessctl)

local awful        = require("awful")
local naughty      = require("naughty")
local math         = math
local tonumber     = tonumber
local string       = string
local os           = os
local dbg          = dbg

-- A bit odd, but...
require("lib/icons")
local icons        = package.loaded["vbe/icons"]

module("vbe/brightness")

local nid = nil
local function change(value)
   -- Set new value
   os.execute("brightnessctl -m s " .. value)

   -- Get and display current value
   current = awful.util.pread("brightnessctl -m i")
   current = tonumber(string.match(current, ",(%d+)%%,"))

   local icon = icons.lookup({name = "display-brightness",
			      type = "status"})

   nid = naughty.notify({ text = string.format("%3d %%", current),
			  icon = icon,
			  font = "Free Sans Bold 24",
			  replaces_id = nid }).id
end

function increase()
   change("5%+")
end

function decrease()
   change("5%-")
end

-- Handle brightness (with gsd-backlight-helper)

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
local function change(percent)
   local cmd = "pkexec /usr/lib/gnome-settings-daemon/gsd-backlight-helper"

   -- Current value
   local current = awful.util.pread(cmd .. " --get-brightness")
   if not current or current == "" then return end
   current = tonumber(current)

   -- Maximum value
   local max = tonumber(awful.util.pread(cmd .. " --get-max-brightness"))

   -- Set new value
   local target = math.floor(current + percent*max / 100)
   target = math.max(0, target)
   target = math.min(max, target)
   os.execute(cmd .. " --set-brightness " .. target)
   current = tonumber(awful.util.pread(cmd .. " --get-brightness"))

   local icon = icons.lookup({name = "display-brightness",
			      type = "status"})

   nid = naughty.notify({ text = string.format("%3d %%", current * 100 / max),
			  icon = icon,
			  font = "Free Sans Bold 24",
			  replaces_id = nid }).id
end

function increase()
   change(5)
end

function decrease()
   change(-5)
end

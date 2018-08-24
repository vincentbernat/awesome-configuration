-- Handle volume (through pulseaudio)

local awful        = require("awful")
local naughty      = require("naughty")
local tonumber     = tonumber
local string       = string
local os           = os

-- A bit odd, but...
require("lib/icons")
local icons        = package.loaded["vbe/icons"]

module("vbe/volume")

local volid = nil
local function change(what)
   os.execute("amixer -q sset Master " .. what, false)
   -- Read the current value
   local out = awful.util.pread("amixer sget Master")
   local vol, mute = out:match("([%d]+)%%.*%[([%l]*)")
   if not mute or not vol then return end

   vol = tonumber(vol)
   local icon = "high"
   if mute ~= "on" or vol == 0 then
      icon = "muted"
   elseif vol < 30 then
      icon = "low"
   elseif vol < 60 then
      icon = "medium"
   end
   icon = icons.lookup({name = "audio-volume-" .. icon,
		       type = "status"})

   volid = naughty.notify({ text = string.format("%3d %%", vol),
			    icon = icon,
			    font = "Free Sans Bold 24",
			    replaces_id = volid }).id
end

function increase()
   change("5%+")
end

function decrease()
   change("5%-")
end

function toggle()
   change("toggle")
end

-- run pavucontrol
function mixer()
   awful.util.spawn("pavucontrol", false)
end

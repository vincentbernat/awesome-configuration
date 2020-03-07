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
local function change(what, how)
   os.execute("amixer -q -D pulse sset " .. what .. " " .. how, false)
   -- Read the current value
   local out = awful.util.pread("amixer -D pulse sget " .. what)
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
   local prefix = "audio-volume"
   if what == "Capture" then
      prefix = "microphone-sensitivity"
   end
   icon = icons.lookup({name = prefix .. "-" .. icon,
		       type = "status"})

   volid = naughty.notify({ text = string.format("%3d %%", vol),
			    icon = icon,
			    font = "Free Sans Bold 24",
			    replaces_id = volid }).id
end

function increase(what)
   change(what, "5%+")
end

function decrease(what)
   change(what, "5%-")
end

function toggle(what)
   change(what, "toggle")
end

-- run pavucontrol
function mixer()
   awful.util.spawn("pavucontrol", false)
end

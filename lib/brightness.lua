-- Handle brightness (with xbacklight)

local awful        = require("awful")
local naughty      = require("naughty")
local tonumber     = tonumber
local string       = string
local os           = os
local dbg          = dbg

-- A bit odd, but...
require("lib/icons")
local icons        = package.loaded["vbe/icons"]

module("vbe/brightness")

local nid = nil
local function change(what)
   os.execute("xbacklight -" .. what)
   local out = awful.util.pread("xbacklight -get")
   if not out or out == "" then return end
   out = tonumber(out)
   local icon = icons.lookup({name = "display-brightness",
			      type = "status"})

   nid = naughty.notify({ text = string.format("%3d %%", out),
			  icon = icon,
			  font = "Free Sans Bold 24",
			  replaces_id = nid }).id
end

function increase()
   change("inc 5")
end

function decrease()
   change("dec 5")
end

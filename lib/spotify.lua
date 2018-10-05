-- Drive spotify

-- Spotify uses the MPRIS D-BUS interface. See more information here:
--   http://specifications.freedesktop.org/mpris-spec/latest/

-- To get the complete interface:
--   mdbus2 org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2

-- Updated to use playerctl instead.

local awful = require("awful")
local dbg   = dbg
local pairs = pairs
local os    = os
local capi = {
   client = client
}

module("vbe/spotify")

-- Get spotify window
local function spotify()
   local clients = capi.client.get()
   for k, c in pairs(clients) do
      if awful.rules.match(c, { instance = "spotify",
                                class = "Spotify" }) then
         return c
      end
   end
   return nil
end

-- Send a command to spotify
local function cmd(command)
   awful.util.spawn("playerctl " .. command, false)
end

-- Show spotify
function show()
   local client = spotify()
   if client then
      if not client:isvisible() then
         awful.tag.viewonly(client:tags()[1])
      end
      capi.client.focus = client
      client:raise()
   else
      awful.util.spawn("spotify")
   end
end

function playpause()
   cmd("play-pause")
end

function play()
   cmd("play")
end

function pause()
   cmd("pause")
end

function stop()
   cmd("stop")
end

function next()
   cmd("next")
end

function previous()
   cmd("previous")
end

function mixer()
   awful.util.spawn("pavucontrol")
end

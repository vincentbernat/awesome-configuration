-- Drive spotify

-- Spotify uses the MPRIS D-BUS interface. See more information here:
--   http://specifications.freedesktop.org/mpris-spec/latest/

-- To get the complete interface:
--   mdbus2 org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2

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
   local client = spotify()
   if client then
      os.execute("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify " ..
         "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player." .. command)
   end
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
   cmd("PlayPause")
end

function play()
   cmd("Play")
end

function pause()
   cmd("Pause")
end

function stop()
   cmd("Stop")
end

function next()
   cmd("Next")
end

function previous()
   cmd("Previous")
end

function mixer()
   awful.util.spawn("pavucontrol")
end

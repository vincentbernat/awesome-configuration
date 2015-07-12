-- Drive spotify

-- Spotify uses the MPRIS D-BUS interface. See more information here:
--   http://specifications.freedesktop.org/mpris-spec/latest/

-- To get the complete interface:
--   mdbus2 org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2

local awful = require("awful")
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
      os.execute("xdotool key --window " .. client.window .. " " .. command)
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
   cmd("space")
end

function play()
   cmd("XF86AudioPlay")
end

function pause()
   cmd("XF86AudioPause")
end

function stop()
   cmd("XF86AudioStop")
end

function next()
   cmd("XF86AudioNext")
end

function previous()
   cmd("XF86AudioPrev")
end

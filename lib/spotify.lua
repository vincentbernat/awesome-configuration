-- Drive spotify

-- Spotify uses the MPRIS D-BUS interface. See more information here:
--   http://specifications.freedesktop.org/mpris-spec/latest/

-- To get the complete interface:
--   mdbus2 org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2

local awful = require("awful")
local pairs = pairs
local capi = {
   client = client
}

module("vbe/spotify")

-- Send a command to spotify
local function spotify(command)
   awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify " ..
      "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player." .. command, false)
end

function playpause()
   spotify("PlayPause")
end

function play()
   -- Play seems unable to play in many situations, let's use
   -- PlayPause instead.
   spotify("PlayPause")
end

function pause()
   spotify("Pause")
end

function stop()
   spotify("Stop")
end

function next()
   spotify("Next")
end

function previous()
   spotify("Previous")
end

function show()
   -- This should work, but no:
   -- spotify("Raise")
   local clients = capi.client.get()
   for k, c in pairs(clients) do
      if awful.rules.match(c, { instance = "spotify",
                                class = "Spotify" }) then
         if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
         end
         capi.client.focus = c
         c:raise()
         return
      end
   end
   awful.util.spawn("spotify")
   -- To disable notifications, add the following line to
   -- ~/.config/spotify/Users/<spotifylogin>-user/prefs:
   --   ui.track_notifications_enabled=false
end

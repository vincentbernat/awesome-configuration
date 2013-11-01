-- Drive spotify

-- Spotify uses the MPRIS D-BUS interface. See more information here:
--   http://specifications.freedesktop.org/mpris-spec/latest/

-- To get the complete interface:
--   mdbus2 org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2

local awful     = require("awful")

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
   awful.util.spawn("spotify")
end

-- Drive spotify

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

-- Quake like console on top
-- See:
--   http://git.sysphere.org/awesome-configs/tree/scratch/drop.lua

local quake = {}		-- List of quake consoles
local height = 0.3

-- When a quake console is closed, remove it from the list
client.add_signal("unmanage",
		  function (c)
		     for i, cl in pairs(quake) do
			if cl == c then
			   quake[i] = nil
			end
		     end
		  end)

-- Toggle the console
local function toggle()
   local cscreen = mouse.screen

   if not quake[cscreen] then
      -- We must spawn a new console

      local function spawn (c)
	 -- We assume that c is our Quake console. 99.9% sure.
	 quake[cscreen] = c

	 -- Setup on top
	 awful.client.floating.set(c, true)
	 c.border_width = 0
	 c.size_hints_honor = false
	 local geom = screen[cscreen].workarea
	 c:geometry({ x = geom.x,
		      y = geom.y,
		      width = geom.width,
		      height = geom.height * height })
	 c.ontop = true
	 c.above = true
	 c.skip_taskbar = true
	 c.sticky = true
	 c:raise()
	 client.focus = c

	 -- Remove our signal handler
	 client.remove_signal("manage", spawn)
      end

      client.add_signal("manage", spawn)
      awful.util.spawn(config.terminal, false)
   else
      -- Display an existing console

      c = quake[cscreen]
      if c.hidden then
	 c.hidden = false
	 c:raise()
	 client.focus = c
      else
	 c.hidden = true
      end
   end
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({ modkey }, "`", toggle))

-- run a command only if the client does not already exist

local xrun_now = function(name, cmd)
   -- Try first the list of clients from awesome (which is available
   -- only if awesome has fully started, therefore, this function
   -- should be run inside a 0 timer)
   local squid = { name, name:sub(1,1):upper() .. name:sub(2) }
   if awful.client.cycle(
      function(c)
	 return awful.rules.match_any(c,
				      { name = squid,
					class = squid,
					instance = squid })
      end)() then
      return
   end

   -- Not found, let's check with xwininfo. We can only check name but
   -- we can catch application without a window...
   if os.execute("xwininfo -name '" .. name .. "' > /dev/null 2> /dev/null") == 0 then
      return
   end
   awful.util.spawn_with_shell(cmd or name)
end

-- Run a command if not already running.
xrun = function(name, cmd)
   -- We need to wait for awesome to be ready. Hence the timer.
   local stimer = timer { timeout = 0 }
   local run = function()
      stimer:stop()
      xrun_now(name, cmd)
   end
   stimer:add_signal("timeout", run)
   stimer:start()
end

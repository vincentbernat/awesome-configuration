-- Menu with xrandr choices

-- Get active outputs
local function outputs()
   local outputs = {}
   local xrandr = io.popen("xrandr -q")
   if xrandr then
      for line in xrandr:lines() do
	 output = line:match("^([%w-]+) connected ")
	 if output then
	    outputs[#outputs + 1] = output
	 end
      end
      xrandr:close()
   end

   return outputs
end

local function arrange(out)
   -- We need to enumerate all the way to combinate output. We assume
   -- we want only an horizontal layout.
   local choices  = {}
   local previous = { {} }
   for i = 1, #out do
      -- Find all permutation of length `i`: we take the permutation
      -- of length `i-1` and for each of them, we create new
      -- permutations by adding each output at the end of it if it is
      -- not already present.
      local new = {}
      for _, p in pairs(previous) do
	 for _, o in pairs(out) do
	    if not awful.util.table.hasitem(p, o) then
	       new[#new + 1] = awful.util.table.join(p, {o})
	    end
	 end
      end
      choices = awful.util.table.join(choices, new)
      previous = new
   end

   return choices
end

-- Display xrandr menu
local function menu()
   local menu = {}
   local out = outputs()
   local choices = arrange(out)

   for _, choice in pairs(choices) do
      local cmd = "xrandr"
      -- Enabled outputs
      for i, o in pairs(choice) do
	 cmd = cmd .. " --output " .. o .. " --auto"
	 if i > 1 then
	    cmd = cmd .. " --right-of " .. choice[i-1]
	 end
      end
      -- Disabled outputs
      for _, o in pairs(out) do
	 if not awful.util.table.hasitem(choice, o) then
	    cmd = cmd .. " --output " .. o .. " -off"
	 end
      end

      local label = ""
      if #choice == 1 then
	 label = 'Only ' .. choice[1]
      else
	 for i, o in pairs(choice) do
	    if i > 1 then label = label .. ", " end
	    label = label .. o
	 end
      end

      menu[#menu + 1] = { " " .. label,
			  function() awful.util.spawn(cmd, false) end,
			  "/usr/share/icons/gnome/32x32/devices/display.png" }
   end

   -- Show the menu
   awful.menu({ items = menu,
		width = 300 }):show({ keygrabber = true })
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({}, "XF86Display", menu))

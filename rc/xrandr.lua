-- Menu with autorandr choices

local icons = loadrc("icons", "vbe/icons")

-- Build available choices
local function menu()
   return {
      { "Autodetect", "autorandr --change" },
      { "Clone", "autorandr --load common" },
      { "Horizontal", "autorandr --load horizontal" },
      { "Vertical", "autorandr --load vertical" },
      { "Keep current configuration", nil },
   }
end

-- Display xrandr notifications from choices
local state = { iterator = nil,
		timer = nil,
		cid = nil }
local function xrandr()
   -- Stop any previous timer
   if state.timer then
      state.timer:stop()
      state.timer = nil
   end

   -- Build the list of choices
   if not state.iterator then
      state.iterator = awful.util.table.cycle(
         menu(),
         function() return true end)
   end

   -- Select one and display the appropriate notification
   local next  = state.iterator()
   local label, action
   if not next then
      state.iterator = nil
      return xrandr()
   else
      label, action = unpack(next)
   end
   state.cid = naughty.notify({ text = label,
				icon = icons.lookup({ name = "display", type = "devices" }),
				timeout = 4,
				screen = mouse.screen, -- Important, not all screens may be visible
				font = "Free Sans 18",
				replaces_id = state.cid }).id

   -- Setup the timer
   state.timer = timer { timeout = 4 }
   state.timer:add_signal("timeout",
			  function()
			     state.timer:stop()
			     state.timer = nil
			     state.iterator = nil
			     if action then
				awful.util.spawn(action, false)
			     end
			  end)
   state.timer:start()
end

config.keys.global = awful.util.table.join(
   config.keys.global,
   awful.key({}, "XF86Display", xrandr))

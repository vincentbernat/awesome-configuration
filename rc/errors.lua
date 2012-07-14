require("awesome")
require("naughty")

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

local colors = {
  header = theme.fg_widget_clock,
  count  = theme.fg_widget_label,
  index  = theme.fg_widget_label,
  name   = theme.fg_widget_value_important,
}

local function dbg_get(var, depth, indent)
  local a = ""
  local text = ""
  local name = ""
  local vtype = type(var)
  local vstring = tostring(var)

  if vtype == "table" or vtype == "userdata" then
    if vtype == "userdata" then var = getmetatable(var) end
    -- element count and longest key
    local count = 0
    local longest_key = 3
    for k,v in pairs(var) do
      count = count + 1
      longest_key = math.max(#tostring(k), longest_key)
    end
    text = text .. vstring .. " <span color='"..colors.count.."'>#" .. count .. "</span>"
    -- descend a table
    if depth > 0 then
      -- sort keys FIXME: messes up sorting number
      local sorted = {}
      for k, v in pairs(var) do table.insert(sorted, { k, v }) end
      table.sort(sorted, function(a, b) return tostring(a[1]) < tostring(b[1]) end)
      -- go through elements
      for _, p in ipairs(sorted) do
        local key = p[1]; local value = p[2]
        -- don't descend _M
        local d; if key ~= "_M" then d = depth - 1 else d = 0 end
        -- get content and add to output
        local content = dbg_get(value, d, indent + longest_key + 1)
        text = text .. '\n' .. string.rep(" ", indent) ..
               string.format("<span color='"..colors.index.."'>%-"..longest_key.."s</span> %s",
                             tostring(key), content)
      end
    end
  else
    if vtype == "tag" or vtype == "client" then
      name = " [<span color='"..colors.name.."'>" .. var.name:sub(1,10) .. "</span>]"
    end
    text = text .. vstring .. name or ""
  end

  return text
end

function dbg(...)
   local num = table.maxn(arg)
   local text = "<span color='"..colors.header.."'>dbg</span> <span color='"..colors.count.."'>#"..num.."</span>"
   local depth = 2

   for i = 1, num do
      local desc = dbg_get(arg[i], depth, 3)
      text = text .. string.format("\n<span color='"..colors.index.."'>%2d</span> %s", i, desc)
   end

   naughty.notify{ text = text, timeout = 0, hover_timeout = 0.05, screen = screen.count() }
end

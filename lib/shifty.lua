--- Shifty: Dynamic tagging library for awesome3-git
-- @author koniu &lt;gkusnierz@gmail.com&gt;
-- @author resixian (aka bioe007) &lt;resixian@gmail.com&gt;
--
-- http://awesome.naquadah.org/wiki/index.php?title=Shifty
--
-- Modified version for my own use (Vincent Bernat)
--
-- TODO:
--   - Maybe name a tag after first client.


-- environment
local type = type
local ipairs = ipairs
local table = table
local string = string
local beautiful = require("beautiful")
local awful = require("awful")
local pairs = pairs
local io = io
local tonumber = tonumber
local dbg= dbg
local capi = {
    client = client,
    tag = tag,
    image = image,
    screen = screen,
    button = button,
    mouse = mouse,
    root = root,
    timer = timer
}

module("vbe/shifty")

-- variables
config = {}
config.tags = {}
config.apps = {}
config.defaults = {}
config.guess_name = true
config.remember_index = true
config.default_name = "…"
config.prompt_sources = {
    "config_tags",
    "config_apps",
    "existing",
    "history"
}
config.prompt_matchers = {
    "^",
    ":",
    ""
}

local matchp = ""
local index_cache = {}
for i = 1, capi.screen.count() do index_cache[i] = {} end

--getname: return the "user" name of a tag
-- @param t : tag
-- @return username of the tag
local function getname(t)
   local name = awful.tag.getproperty(t, "shortname")
   if name then
      return "" .. name
   end
   return t.name
end

--setname: set the "user" name of a tag and update its name
-- @param t : tag
-- @param name : new name
local function setname(t, name)
   if name then
      local dispname = "" .. name
      local pos = awful.tag.getproperty(t, "position")
      awful.tag.setproperty(t, "shortname", name)
      if pos then
         if "" .. pos ~= "" .. dispname then
            dispname = pos .. '↭' .. dispname
         end
      end
      t.name = dispname
   end
end

--freeposition: get a free position
local function freeposition()
   local positions = {1, 2, 3, 4, 5, 6, 7, 8, 9}
   for k, a in pairs(config.tags) do
      if a.startup then
         a = awful.util.table.join(a, a.startup)
      end
      if a.position then
         local idx = awful.util.table.hasitem(positions, a.position)
         if idx then
            table.remove(positions, idx)
         end
      end
   end
   for s = 1, capi.screen.count() do
      for i, t in ipairs(capi.screen[s]:tags()) do
         local pos = awful.tag.getproperty(t, "position")
         if pos then
            local idx = awful.util.table.hasitem(positions, pos)
            if idx then
               table.remove(positions, idx)
            end
         end
      end
   end
   if #positions > 0 then
      return positions[1]
   end
   return nil
end

--name2tags: matches string 'name' to tag objects
-- @param name : tag name to find
-- @param scr : screen to look for tags on
-- @return table of tag objects or nil
function name2tags(name, scr)
    local ret = {}
    local a, b = scr or 1, scr or capi.screen.count()
    for s = a, b do
        for i, t in ipairs(capi.screen[s]:tags()) do
           if name == getname(t) then
                table.insert(ret, t)
            end
        end
    end
    if #ret > 0 then return ret end
end

function name2tag(name, scr, idx)
    local ts = name2tags(name, scr)
    if ts then return ts[idx or 1] end
end

--tag2index: finds index of a tag object
-- @param scr : screen number to look for tag on
-- @param tag : the tag object to find
-- @return the index [or zero] or end of the list
function tag2index(scr, tag)
    for i, t in ipairs(capi.screen[scr]:tags()) do
        if t == tag then return i end
    end
end

--rename
--@param tag: tag object to be renamed
function rename(tag, no_selectall)
    local theme = beautiful.get()
    local t = tag or awful.tag.selected(capi.mouse.screen)
    local scr = t.screen
    local bg = nil
    local fg = nil
    local text = getname(t)
    local before = getname(t)

    if t == awful.tag.selected(scr) then
        bg = theme.bg_focus or '#535d6c'
        fg = theme.fg_urgent or '#ffffff'
    else
        bg = theme.bg_normal or '#222222'
        fg = theme.fg_urgent or '#ffffff'
    end

    awful.prompt.run({
        fg_cursor = fg, bg_cursor = bg, ul_cursor = "single",
        text = text, selectall = not no_selectall},
        taglist[scr][tag2index(scr, t) * 2],
        function (name) if name:len() > 0 then setname(t, name); end end,
        completion,
        awful.util.getdir("cache") .. "/history_tags",
        nil,
        function ()
            if getname(t) == before then
                if awful.tag.getproperty(t, "initial") then del(t) end
            else
                awful.tag.setproperty(t, "initial", true)
                set(t)
            end
            t:emit_signal("property::name")
        end
        )
end

--send: moves client to tag[idx]
-- maybe this isn't needed here in shifty?
-- @param idx the tag number to send a client to
function send(idx)
    local scr = capi.client.focus.screen or capi.mouse.screen
    local sel = awful.tag.selected(scr)
    local sel_idx = tag2index(scr, sel)
    local tags = capi.screen[scr]:tags()
    local target = awful.util.cycle(#tags, sel_idx + idx)
    awful.client.movetotag(tags[target], capi.client.focus)
    awful.tag.viewonly(tags[target])
end

function send_next() send(1) end
function send_prev() send(-1) end

--pos2idx: translate shifty position to tag index
--@param pos: position (an integer)
--@param scr: screen number
function pos2idx(pos, scr)
    local v = 1
    if pos and scr then
        for i = #capi.screen[scr]:tags() , 1, -1 do
            local t = capi.screen[scr]:tags()[i]
            if awful.tag.getproperty(t, "position") and
                awful.tag.getproperty(t, "position") <= pos then
                v = i + 1
                break
            end
        end
    end
    return v
end

--select : helper function chooses the first non-nil argument
--@param args - table of arguments
function select(args)
    for i, a in pairs(args) do
        if a ~= nil then
            return a
        end
    end
end

--tagtoscr : move an entire tag to another screen
--
--@param scr : the screen to move tag to
--@param t : the tag to be moved [awful.tag.selected()]
--@return the tag
function tagtoscr(scr, t)
    -- break if called with an invalid screen number
    if not scr or scr < 1 or scr > capi.screen.count() then return end
    -- tag to move
    local otag = t or awful.tag.selected()

    otag.screen = scr
    -- set screen and then reset tag to order properly
    if #otag:clients() > 0 then
        for _ , c in ipairs(otag:clients()) do
            if not c.sticky then
                c.screen = scr
                c:tags({otag})
            else
                awful.client.toggletag(otag, c)
            end
        end
    end
    return otag
end

--set : set a tags properties
--@param t: the tag
--@param args : a table of optional (?) tag properties
--@return t - the tag object
function set(t, args)
    if not t then return end
    if not args then args = {} end

    -- set the name
    setname(t, args.name or getname(t))

    -- attempt to load preset on initial run
    local preset = (awful.tag.getproperty(t, "initial") and
                    config.tags[getname(t)]) or {}

    -- pick screen and get its tag table
    local scr = args.screen or
    (not t.screen and preset.screen) or
    t.screen or
    capi.mouse.screen

    local clientstomove = nil
    if scr > capi.screen.count() then scr = capi.screen.count() end
    if t.screen and scr ~= t.screen then
        tagtoscr(scr, t)
        t.screen = nil
    end
    local tags = capi.screen[scr]:tags()

    -- allow preset.layout to be a table to provide a different layout per
    -- screen for a given tag
    local preset_layout = preset.layout
    if preset_layout and preset_layout[scr] then
        preset_layout = preset.layout[scr]
    end

    -- select from args, preset, getproperty,
    -- config.defaults.configs or defaults
    local props = {
        layout = select{args.layout, preset_layout,
                        awful.tag.getproperty(t, "layout"),
                        config.defaults.layout, awful.layout.suit.tile},
        mwfact = select{args.mwfact, preset.mwfact,
                        awful.tag.getproperty(t, "mwfact"),
                        config.defaults.mwfact, 0.55},
        nmaster = select{args.nmaster, preset.nmaster,
                        awful.tag.getproperty(t, "nmaster"),
                        config.defaults.nmaster, 1},
        ncol = select{args.ncol, preset.ncol,
                        awful.tag.getproperty(t, "ncol"),
                        config.defaults.ncol, 1},
        matched = select{args.matched, awful.tag.getproperty(t, "matched")},
        exclusive = select{args.exclusive, preset.exclusive,
                        awful.tag.getproperty(t, "exclusive"),
                        config.defaults.exclusive},
        persist = select{args.persist, preset.persist,
                        awful.tag.getproperty(t, "persist"),
                        config.defaults.persist},
        nopopup = select{args.nopopup, preset.nopopup,
                        awful.tag.getproperty(t, "nopopup"),
                        config.defaults.nopopup},
        leave_kills = select{args.leave_kills, preset.leave_kills,
                        awful.tag.getproperty(t, "leave_kills"),
                        config.defaults.leave_kills},
        max_clients = select{args.max_clients, preset.max_clients,
                        awful.tag.getproperty(t, "max_clients"),
                        config.defaults.max_clients},
        position = select{args.position, preset.position,
                          awful.tag.getproperty(t, "position"), freeposition()},
        icon = select{args.icon and capi.image(args.icon),
                        preset.icon and capi.image(preset.icon),
                        awful.tag.getproperty(t, "icon"),
                    config.defaults.icon and capi.image(config.defaults.icon)},
        icon_only = select{args.icon_only, preset.icon_only,
                        awful.tag.getproperty(t, "icon_only"),
                        config.defaults.icon_only},
        sweep_delay = select{args.sweep_delay, preset.sweep_delay,
                        awful.tag.getproperty(t, "sweep_delay"),
                        config.defaults.sweep_delay},
    }

    -- calculate desired taglist index
    local index = args.index or preset.index or config.defaults.index
    local rel_index = args.rel_index or
    preset.rel_index or
    config.defaults.rel_index
    local sel = awful.tag.selected(scr)
    --TODO: what happens with rel_idx if no tags selected
    local sel_idx = (sel and tag2index(scr, sel)) or 0
    local t_idx = tag2index(scr, t)
    local limit = (not t_idx and #tags + 1) or #tags
    local idx = nil

    if rel_index then
        idx = awful.util.cycle(limit, (t_idx or sel_idx) + rel_index)
    elseif index then
        idx = awful.util.cycle(limit, index)
    elseif props.position then
        idx = pos2idx(props.position, scr)
        if t_idx and t_idx < idx then idx = idx - 1 end
    elseif config.remember_index and index_cache[scr][getname(t)] then
        idx = index_cache[scr][getname(t)]
    elseif not t_idx then
        idx = #tags + 1
    end

    -- if we have a new index, remove from old index and insert
    if idx then
        if t_idx then table.remove(tags, t_idx) end
        table.insert(tags, idx, t)
        index_cache[scr][getname(t)] = idx
    end

    -- set tag properties and push the new tag table
    capi.screen[scr]:tags(tags)
    for prop, val in pairs(props) do awful.tag.setproperty(t, prop, val) end

    -- execute run/spawn
    if awful.tag.getproperty(t, "initial") then
        local spawn = args.spawn or preset.spawn or config.defaults.spawn
        local run = args.run or preset.run or config.defaults.run
        if spawn and args.matched ~= true then
            awful.util.spawn_with_shell(spawn, scr)
        end
        if run then run(t) end
        awful.tag.setproperty(t, "initial", nil)
    end


    return t
end

function shift_next() set(awful.tag.selected(), {rel_index = 1}) end
function shift_prev() set(awful.tag.selected(), {rel_index = -1}) end

--add : adds a tag
--@param args: table of optional arguments
function add(args)
    if not args then args = {} end
    local name = args.name or " "

    -- initialize a new tag object and its data structure
    local t = capi.tag{name = name}

    -- tell set() that this is the first time
    awful.tag.setproperty(t, "initial", true)

    -- apply tag settings
    set(t, args)

    -- unless forbidden or if first tag on the screen, show the tag
    if not (awful.tag.getproperty(t, "nopopup") or args.noswitch) or
        #capi.screen[t.screen]:tags() == 1 then
        awful.tag.viewonly(t)
    end

    -- get the name or rename
    if args.name then
       setname(t, args.name)
    else
        -- FIXME: hack to delay rename for un-named tags for
        -- tackling taglist refresh which disabled prompt
        -- from being rendered until input
        awful.tag.setproperty(t, "initial", true)
        local tmr
        local f = function() rename(t); tmr:stop() end
        tmr = capi.timer({timeout = 0.01})
        tmr:add_signal("timeout", f)
        tmr:start()
    end

    return t
end

--del : delete a tag
--@param tag : the tag to be deleted [current tag]
function del(tag)
    local scr = (tag and tag.screen) or capi.mouse.screen or 1
    local tags = capi.screen[scr]:tags()
    local sel = awful.tag.selected(scr)
    local t = tag or sel
    local idx = tag2index(scr, t)

    -- return if tag not empty (except sticky)
    local clients = t:clients()
    local sticky = 0
    for i, c in ipairs(clients) do
        if c.sticky then sticky = sticky + 1 end
    end
    if #clients > sticky then return end

    -- store index for later
    index_cache[scr][getname(t)] = idx

    -- remove tag
    t.screen = nil

    -- if the current tag is being deleted, restore from history
    if t == sel and #tags > 1 then
        awful.tag.history.restore(scr, 1)
        -- this is supposed to cycle if history is invalid?
        -- e.g. if many tags are deleted in a row
        if not awful.tag.selected(scr) then
            awful.tag.viewonly(tags[awful.util.cycle(#tags, idx - 1)])
        end
    end

    -- FIXME: what is this for??
    if capi.client.focus then capi.client.focus:raise() end
end

--is_client_tagged : replicate behavior in tag.c - returns true if the
--given client is tagged with the given tag
function is_client_tagged(tag, client)
    for i, c in ipairs(tag:clients()) do
        if c == client then
            return true
        end
    end
    return false
end

--match : handles app->tag matching, a replacement for the manage hook in
--            rc.lua
--@param c : client to be matched
function match(c, startup)
    local nopopup, intrusive, nofocus, run, slave
    local target_tag_names, target_tags = {}, {}
    local typ = c.type
    local cls = c.class
    local inst = c.instance
    local role = c.role
    local name = c.name
    local target_screen = capi.mouse.screen

    -- try matching client to config.apps
    for i, a in ipairs(config.apps) do
        if a.match then
            local matched = false
            -- match function
            if not matched and a.match.check then
               matched = a.match.check(c)
            end

            -- match only class
            if not matched and cls and a.match.class then
                for k, w in ipairs(a.match.class) do
                    matched = cls:find(w)
                    if matched then
                        break
                    end
                end
            end
            -- match only instance
            if not matched and inst and a.match.instance then
                for k, w in ipairs(a.match.instance) do
                    matched = inst:find(w)
                    if matched then
                        break
                    end
                end
            end
            -- match only name
            if not matched and name and a.match.name then
                for k, w in ipairs(a.match.name) do
                    matched = name:find(w)
                    if matched then
                        break
                    end
                end
            end
            -- match only role
            if not matched and role and a.match.role then
                for k, w in ipairs(a.match.role) do
                    matched = role:find(w)
                    if matched then
                        break
                    end
                end
            end
            -- match only type
            if not matched and typ and a.match.type then
                for k, w in ipairs(a.match.type) do
                    matched = typ:find(w)
                    if matched then
                        break
                    end
                end
            end
            -- check everything else against all attributes
            if not matched then
                for k, w in ipairs(a.match) do
                    matched = (cls and cls:find(w)) or
                            (inst and inst:find(w)) or
                            (name and name:find(w)) or
                            (role and role:find(w)) or
                            (typ and typ:find(w))
                    if matched then
                        break
                    end
                end
            end
            -- set attributes
            if matched then
                if a.startup and startup then
                    a = awful.util.table.join(a, a.startup)
                end
                if a.screen then target_screen = a.screen end
                if a.tag then
                    if type(a.tag) == "string" then
                        target_tag_names = {a.tag}
                    else
                        target_tag_names = a.tag
                    end
                end
                if a.slave ~=nil then slave = a.slave end
                if a.nopopup ~=nil then nopopup = a.nopopup end
                if a.intrusive ~=nil then
                    intrusive = a.intrusive
                end
                if a.nofocus ~= nil then nofocus = a.nofocus end
                if a.run ~= nil then run = a.run end
                if a.props then
                    for kk, vv in pairs(a.props) do
                        awful.client.property.set(c, kk, vv)
                    end
                end
            end
        end
    end

    local sel = awful.tag.selectedlist(target_screen)
    if not target_tag_names or #target_tag_names == 0 then
        -- if not matched to some names try putting
        -- client in c.transient_for or current tags
        if c.transient_for then
            target_tags = c.transient_for:tags()
        elseif #sel > 0 then
            for i, t in ipairs(sel) do
                local mc = awful.tag.getproperty(t, "max_clients")
                if intrusive or c.type == "dialog" or
                    not (awful.tag.getproperty(t, "exclusive") or
                                    (mc and mc >= #t:clients())) then
                    table.insert(target_tags, t)
                    if config.guess_name and cls then
                       if getname(t) == config.default_name or
                          getname(t) == "" .. awful.tag.getproperty(t, "position") then
                          setname(t, cls:lower())
                       end
                    end
                end
            end
        end
    end

    if (not target_tag_names or #target_tag_names == 0) and
        (not target_tags or #target_tags == 0) then
        -- if we still don't know any target names/tags guess
        -- name from class or use default
        if config.guess_name and cls then
            target_tag_names = {cls:lower()}
        else
            target_tag_names = {config.default_name}
        end
    end

    if #target_tag_names > 0 and #target_tags == 0 then
        -- translate target names to tag objects, creating
        -- missing ones
        for i, tn in ipairs(target_tag_names) do
            local res = {}
            for j, t in ipairs(name2tags(tn, target_screen) or
                name2tags(tn) or {}) do
                local mc = awful.tag.getproperty(t, "max_clients")
                local tagged = is_client_tagged(t, c)
                if intrusive or
                    not (mc and (((#t:clients() >= mc) and not
                    tagged) or
                    (#t:clients() > mc))) or
                    intrusive then
                    table.insert(res, t)
                end
            end
            if #res == 0 then
                table.insert(target_tags,
                add({name = tn,
                noswitch = true,
                matched = true}))
            else
                target_tags = awful.util.table.join(target_tags, res)
            end
        end
    end

    -- set client's screen/tag if needed
    target_screen = target_tags[1].screen or target_screen
    if c.screen ~= target_screen then c.screen = target_screen end
    if slave then awful.client.setslave(c) end
    c:tags(target_tags)

    local showtags = {}
    local u = nil
    if #target_tags > 0 and not startup then
        -- switch or highlight
        for i, t in ipairs(target_tags) do
            if not (nopopup or awful.tag.getproperty(t, "nopopup")) then
                table.insert(showtags, t)
            elseif not startup then
                c.urgent = true
            end
        end
        if #showtags > 0 then
            local ident = false
            -- iterate selected tags and and see if any targets
            -- currently selected
            for kk, vv in pairs(showtags) do
                for _, tag in pairs(sel) do
                    if tag == vv then
                        ident = true
                    end
                end
            end
            if not ident then
                awful.tag.viewmore(showtags, c.screen)
            end
        end
    end

    if nofocus then
        --focus and raise accordingly or lower if supressed
        if (target and target ~= sel) and
           (awful.tag.getproperty(target, "nopopup") or nopopup)  then
            awful.client.focus.history.add(c)
        else
            capi.client.focus = c
        end
        c:raise()
    else
        c:lower()
    end

    -- execute run function if specified
    if run then run(c, target) end

end

--sweep : hook function that marks tags as used, visited,
--deserted also handles deleting used and empty tags
function sweep()
    for s = 1, capi.screen.count() do
        for i, t in ipairs(capi.screen[s]:tags()) do
            local clients = t:clients()
            local sticky = 0
            for i, c in ipairs(clients) do
                if c.sticky then sticky = sticky + 1 end
            end
            if #clients == sticky then
                if awful.tag.getproperty(t, "used") and
                    not awful.tag.getproperty(t, "persist") then
                    if awful.tag.getproperty(t, "deserted") or
                        not awful.tag.getproperty(t, "leave_kills") then
                        local delay = awful.tag.getproperty(t, "sweep_delay")
                        if delay then
                            local tmr
                            local f = function()
                               del(t)
                               tmr:stop()
                            end
                            tmr = capi.timer({timeout = delay})
                            tmr:add_signal("timeout", f)
                            tmr:start()
                        else
                            del(t)
                        end
                    else
                        if awful.tag.getproperty(t, "visited") and
                            not t.selected then
                            awful.tag.setproperty(t, "deserted", true)
                        end
                    end
                end
            else
                awful.tag.setproperty(t, "used", true)
            end
            if t.selected then
                awful.tag.setproperty(t, "visited", true)
            end
        end
    end
end

--getpos : returns a tag to match position
-- @param pos : the index to find
-- @return v : the tag (found or created) at position == 'pos'
function getpos(pos, scr_arg)
    local v = nil
    local existing = {}
    local selected = nil
    local scr = scr_arg or capi.mouse.screen or 1

    -- search for existing tag assigned to pos
    for i = 1, capi.screen.count() do
        for j, t in ipairs(capi.screen[i]:tags()) do
            if awful.tag.getproperty(t, "position") == pos then
                table.insert(existing, t)
                if t.selected and i == scr then
                    selected = #existing
                end
            end
        end
    end

    if #existing > 0 then
        -- if making another of an existing tag, return the end of
        -- the list the optional 2nd argument decides if we return
        -- only
        if scr_arg ~= nil then
            for _, tag in pairs(existing) do
                if tag.screen == scr_arg then return tag end
            end
            -- no tag with a position and scr_arg match found, clear
            -- v and allow the subseqeunt conditions to be evaluated
            v = nil
        else
            v = (selected and
                    existing[awful.util.cycle(#existing, selected + 1)]) or
                    existing[1]
        end

    end
    if not v then
        -- search for preconf with 'pos' and create it
        for i, j in pairs(config.tags) do
            if j.position == pos then
                v = add({name = i,
                        position = pos,
                        noswitch = not switch})
            end
        end
    end
    if not v then
        -- not existing, not preconfigured
        v = add({position = pos,
                name = pos,
                noswitch = not switch})
    end
    return v
end

--init : search shifty.config.tags for initial set of
--tags to open
function init()
    local numscr = capi.screen.count()

    for i, j in pairs(config.tags) do
        local scr = j.screen or {1}
        if type(scr) ~= 'table' then
            scr = {scr}
        end
        for _, s in pairs(scr) do
            if j.init and (s <= numscr) then
                add({name = i,
                    persist = true,
                    screen = s,
                    layout = j.layout,
                    mwfact = j.mwfact})
            end
        end
    end
end

--count : utility function returns the index of a table element
--FIXME: this is currently used only in remove_dup, so is it really
--necessary?
function count(table, element)
    local v = 0
    for i, e in pairs(table) do
        if element == e then v = v + 1 end
    end
    return v
end

--remove_dup : used by shifty.completion when more than one
--tag at a position exists
function remove_dup(table)
    local v = {}
    for i, entry in ipairs(table) do
        if count(v, entry) == 0 then v[#v+ 1] = entry end
    end
    return v
end

--completion : prompt completion
--
function completion(cmd, cur_pos, ncomp, sources, matchers)

    -- get sources and matches tables
    sources = sources or config.prompt_sources
    matchers = matchers or config.prompt_matchers

    local get_source = {
        -- gather names from config.tags
        config_tags = function()
            local ret = {}
            for n, p in pairs(config.tags) do
                table.insert(ret, n)
            end
            return ret
        end,
        -- gather names from config.apps
        config_apps = function()
            local ret = {}
            for i, p in pairs(config.apps) do
                if p.tag then
                    if type(p.tag) == "string" then
                        table.insert(ret, p.tag)
                    else
                        ret = awful.util.table.join(ret, p.tag)
                    end
                end
            end
            return ret
        end,
        -- gather names from existing tags, starting with the
        -- current screen
        existing = function()
            local ret = {}
            for i = 1, capi.screen.count() do
                local s = awful.util.cycle(capi.screen.count(),
                                            capi.mouse.screen + i - 1)
                local tags = capi.screen[s]:tags()
                for j, t in pairs(tags) do
                   table.insert(ret, getname(t))
                end
            end
            return ret
        end,
        -- gather names from history
        history = function()
            local ret = {}
            local f = io.open(awful.util.getdir("cache") ..
                                    "/history_tags")
            for name in f:lines() do table.insert(ret, name) end
            f:close()
            return ret
        end,
    }

    -- if empty, match all
    if #cmd == 0 or cmd == " " then cmd = "" end

    -- match all up to the cursor if moved or no matchphrase
    if matchp == "" or
        cmd:sub(cur_pos, cur_pos+#matchp) ~= matchp then
        matchp = cmd:sub(1, cur_pos)
    end

    -- find matching commands
    local matches = {}
    for i, src in ipairs(sources) do
        local source = get_source[src]()
        for j, matcher in ipairs(matchers) do
            for k, name in ipairs(source) do
                if name:find(matcher .. matchp) then
                    table.insert(matches, name)
                end
            end
        end
    end

    -- no matches
    if #matches == 0 then return cmd, cur_pos end

    -- remove duplicates
    matches = remove_dup(matches)

    -- cycle
    while ncomp > #matches do ncomp = ncomp - #matches end

    -- put cursor at the end of the matched phrase
    if #matches == 1 then
        cur_pos = #matches[ncomp] + 1
    else
        cur_pos = matches[ncomp]:find(matchp) + #matchp
    end

    -- return match and position
    return matches[ncomp], cur_pos
end

-- signals
capi.client.add_signal("manage", match)
capi.client.add_signal("unmanage", sweep)
capi.client.remove_signal("manage", awful.tag.withcurrent)

for s = 1, capi.screen.count() do
    awful.tag.attached_add_signal(s, "property::selected", sweep)
    awful.tag.attached_add_signal(s, "tagged", sweep)
end


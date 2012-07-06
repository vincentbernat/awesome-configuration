-- functions to share tags on multiple screens

--{{{ Grab environment we need
local capi = { widget = widget,
               screen = screen,
               image = image,
               client = client,
               button = button }
local setmetatable = setmetatable
local math = math
local type = type
local pcall = pcall
local util = require("awful.util")
local tag = require("awful.tag")
local beautiful = require("beautiful")
local layout = require("awful.widget.layout")

local awful = require("awful") 
local mouse = mouse

local pairs = pairs
local ipairs = ipairs
--}}}

module("sharetags")

--{{{ Private structures
tagwidgets = setmetatable({}, { __mode = 'k' })
local cachedtags = {}
label = {}
--}}}

--{{{ Functions

--{{{ create_tags: create a table of tags and bind them to screens
-- @param names : list to label the tags
-- @param layouts : list of layouts for the tags
-- @return table of tag objects
function create_tags(names, layouts)
    local tags = {}
    local count = #names
    if capi.screen.count() >= #names then
        count = capi.screen.count() + 1
    end
    for tagnumber = 1, count do
        tags[tagnumber] = awful.tag.add(names[tagnumber], {})
        tag.setproperty(tags[tagnumber], "number", tagnumber)
        -- Add tags to screen one by one
        tags[tagnumber].screen = 1
        awful.layout.set(layouts[tagnumber], tags[tagnumber])
    end
    for s = 1, capi.screen.count() do
        -- I'm sure you want to see at least one tag.
        tags[s].screen = s
        tags[s].selected = true
    end
    cachedtags = tags
    return tags
end
--}}}

--{{{ tag_move: move a tag to a screen
-- @param t : the tag object to move
-- @param scr : the screen object to move to
function tag_move(t, scr)
    local ts = t or awful.tag.selected()
    local screen_target = scr or awful.util.cycle(capi.screen.count(), ts.screen + 1)

    if ts.screen and screen_target ~= ts.screen then
        -- switch for tag
        ts.screen = screen_target
        -- switch for all clients on tag
        if #ts:clients() > 0 then
            for _ , c in ipairs(ts:clients()) do
                if not c.sticky then
                    c.screen = screen_target
                    c:tags( {ts} )
                else
                    awful.client.toggletag(ts,c)
                end
            end
        end
    end
end
--}}}

--{{{ tag_to_screen: move a tag to a screen if its not already there
-- @param t : the tag object to move
-- @param scr : the screen object to move to
function tag_to_screen(t, scr)
    local ts = t or awful.tag.selected()
    local screen_origin = ts.screen
    local screen_target = scr or awful.util.cycle(capi.screen.count(), ts.screen + 1)

    awful.tag.history.restore(ts.screen,1)
    -- move the tag only if we are on a different screen
    if screen_origin ~= screen_target then
        tag_move(ts, screen_target)
    end

    awful.tag.viewonly(ts)
    mouse.screen = ts.screen
    if #ts:clients() > 0 then
        local c = ts:clients()[1]
        capi.client.focus = c
    end
end
--}}}

--{{{ Return labels for a taglist widget with all tag from screen.
-- It returns the tag name and set a special
-- foreground and background color for selected tags.
-- @param t The tag.
-- @param args The arguments table.
-- bg_focus The background color for selected tag.
-- fg_focus The foreground color for selected tag.
-- bg_urgent The background color for urgent tags.
-- fg_urgent The foreground color for urgent tags.
-- squares_sel Optional: a user provided image for selected squares.
-- squares_unsel Optional: a user provided image for unselected squares.
-- squares_resize Optional: true or false to resize squares.
-- @return A string to print, a background color, a background image and a
-- background resize value.
function label.all(t, args)
    if not args then args = {} end
    local theme = beautiful.get()
    local fg_focus = args.fg_focus or theme.taglist_fg_focus or theme.fg_focus
    local bg_focus = args.bg_focus or theme.taglist_bg_focus or theme.bg_focus
    local fg_urgent = args.fg_urgent or theme.taglist_fg_urgent or theme.fg_urgent
    local bg_urgent = args.bg_urgent or theme.taglist_bg_urgent or theme.bg_urgent
    local bg_occupied = args.bg_occupied or theme.taglist_bg_occupied
    local fg_occupied = args.fg_occupied or theme.taglist_fg_occupied
    local taglist_squares_sel = args.squares_sel or theme.taglist_squares_sel
    local taglist_squares_unsel = args.squares_unsel or theme.taglist_squares_unsel
    local taglist_squares_resize = theme.taglist_squares_resize or args.squares_resize or "true"
    local font = args.font or theme.taglist_font or theme.font or ""
    local text = "<span font_desc='"..font.."'>"
    local sel = capi.client.focus
    local bg_color = nil
    local fg_color = nil
    local bg_image
    local icon
    local bg_resize = false
    local is_selected = false
    if not args.screen then
        args.screen = t.screen
    end
    if t.selected and t.screen == args.screen then
        bg_color = bg_focus
        fg_color = fg_focus
    end
    if sel and sel.type ~= "desktop" then
        if taglist_squares_sel then
            -- Check that the selected clients is tagged with 't'.
            local seltags = sel:tags()
            for _, v in ipairs(seltags) do
                if v == t then
                    bg_image = capi.image(taglist_squares_sel)
                    bg_resize = taglist_squares_resize == "true"
                    is_selected = true
                    break
                end
            end
        end
    end
    if not is_selected then
        local cls = t:clients()
        if #cls > 0 then
            if taglist_squares_unsel then
                bg_image = capi.image(taglist_squares_unsel)
                bg_resize = taglist_squares_resize == "true"
            end
            if bg_occupied then bg_color = bg_occupied end
            if fg_occupied then fg_color = fg_occupied end
        end
        for k, c in pairs(cls) do
            if c.urgent then
                if bg_urgent then bg_color = bg_urgent end
                if fg_urgent then fg_color = fg_urgent end
                break
            end
        end
    end
    if not tag.getproperty(t, "icon_only") then
        if fg_color then
            text = text .. "<span color='"..util.color_strip_alpha(fg_color).."'>"
            text = " " .. text.. (util.escape(t.name) or "") .." </span>"
        else
            text = text .. " " .. (util.escape(t.name) or "") .. " "
        end
    end
    text = text .. "</span>"
    if tag.geticon(t) and type(tag.geticon(t)) == "image" then
        icon = tag.geticon(t)
    elseif tag.geticon(t) then
        icon = capi.image(tag.geticon(t))
    end

    return text, bg_color, bg_image, icon
end
--}}}

--{{{ list_update: update a list of widgets
-- @param screen : the screen to draw the taglist for
-- @param w : the widget container
-- @param label : label function to use
-- @param buttons : a table with button bindings to set
-- @param widgets : a table with widget style parameters
-- @param objects : the list of tags to be displayed
-- @param scr : the current screen
local function list_update(w, buttons, label, data, widgets, objects, scr)
    -- Hack: if it has been registered as a widget in a wibox,
    -- it's w.len since __len meta does not work on table until Lua 5.2.
    -- Otherwise it's standard #w.
    local len = (w.len or #w) / 2
    -- Add more widgets
    if len < #objects then
        for i = len * 2 + 1, #objects * 2, 2 do
            local ib = capi.widget({ type = "imagebox", align = widgets.imagebox.align })
            local tb = capi.widget({ type = "textbox", align = widgets.textbox.align })

            w[i] = ib
            w[i + 1] = tb
            w[i + 1]:margin({ left = widgets.textbox.margin.left, right = widgets.textbox.margin.right })
            w[i + 1].bg_resize = widgets.textbox.bg_resize or false
            w[i + 1].bg_align = widgets.textbox.bg_align or ""

            if type(objects[math.floor(i / 2) + 1]) == "tag" then
                tagwidgets[ib] = objects[math.floor(i / 2) + 1]
                tagwidgets[tb] = objects[math.floor(i / 2) + 1]
            end
        end
    -- Remove widgets
    elseif len > #objects then
        for i = #objects * 2 + 1, len * 2, 2 do
            w[i] = nil
            w[i + 1] = nil
        end
    end

    -- update widgets text
    for k = 1, #objects * 2, 2 do
        local o = objects[(k + 1) / 2]
        if not o then
            o = objects[(k-1) / 2]
        end
        if buttons then
            -- Use a local variable so that the garbage collector doesn't strike
            -- between now and the :buttons() call.
            local btns = data[o]
            if not btns then
                btns = {}
                data[o] = btns
                for kb, b in ipairs(buttons) do
                    -- Create a proxy button object: it will receive the real
                    -- press and release events, and will propagate them the the
                    -- button object the user provided, but with the object as
                    -- argument.
                    local btn = capi.button { modifiers = b.modifiers, button = b.button }
                    btn:add_signal("press", function () b:emit_signal("press", o) end)
                    btn:add_signal("release", function () b:emit_signal("release", o) end)
                    btns[#btns + 1] = btn
                end
            end
            w[k]:buttons(btns)
            w[k + 1]:buttons(btns)
        end

        args = { screen = scr }
        local text, bg, bg_image, icon = label(o, args)

        -- Check if we got a valid text here, it might contain e.g. broken utf8.
        if not pcall(function() w[k + 1].text = text end) then
            w[k + 1].text = "<i>Invalid</i>"
        end

        w[k + 1].bg, w[k + 1].bg_image = bg, bg_image
        w[k].bg, w[k].image = bg, icon
        if not w[k + 1].text then
            w[k+1].visible = false
        else
            w[k+1].visible = true
        end
        if not w[k].image then
            w[k].visible = false
        else
            w[k].visible = true
        end
   end
end
--}}}

--{{{ taglist_update: update the taglist widget
-- @param screen : the screen to draw the taglist for
-- @param w : the taglist widget
-- @param label : label function to use
-- @param buttons : a table with button bindings to set
-- @param widgets : a table with widget style parameters
-- @param objects : the list of tags to be displayed
local function taglist_update (screen, w, label, buttons, data, widgets)
    list_update(w, buttons, label, data, widgets, cachedtags, screen)
end
--}}}

--{{{ taglist: create a taglist widget for the shared tags
-- @param screen : the screen to draw the taglist for
-- @param label : label function to use
-- @param buttons : a table with button bindings to set
function taglist(screen, label, buttons)
    local w = {
        layout = layout.horizontal.leftright
    }
    local widgets = { }
    widgets.imagebox = { }
    widgets.textbox  = { ["margin"] = { ["left"]  = 0,
                                        ["right"] = 0},
                         ["bg_resize"] = true
                       }
    local data = setmetatable({}, { __mode = 'kv' })
    local u = function (s)
        if s == screen then
            taglist_update(s, w, label, buttons, data, widgets)
        end
    end
    local uc = function (c) return u(c.screen) end
    capi.client.add_signal("focus", uc)
    capi.client.add_signal("unfocus", uc)
    tag.attached_add_signal(screen, "property::selected", uc)
    tag.attached_add_signal(screen, "property::icon", uc)
    tag.attached_add_signal(screen, "property::hide", uc)
    tag.attached_add_signal(screen, "property::name", uc)
    capi.screen[screen]:add_signal("tag::attach", function(screen, tag)
            u(screen.index)
        end)
    capi.screen[screen]:add_signal("tag::detach", function(screen, tag)
            u(screen.index)
        end)
    capi.client.add_signal("new", function(c)
        c:add_signal("property::urgent", uc)
        c:add_signal("property::screen", function(c)
            -- If client change screen, refresh it anyway since we don't from
            -- which screen it was coming :-)
            u(screen)
        end)
        c:add_signal("tagged", uc)
        c:add_signal("untagged", uc)
    end)
    capi.client.add_signal("unmanage", uc)
    u(screen)
    return w
end
--}}}

--}}}

-- vim: fdm=marker:

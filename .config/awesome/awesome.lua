local awful = require("awful")
local awful_rules = require("awful.rules")
local awful_autofocus = require("awful.autofocus")
local eminent = require("eminent")
local vicious = require("vicious")
-- Theme handling library
local beautiful = require("beautiful")
beautiful.init(confdir .. "/themes/current/theme.lua")
-- Notification library
local naughty = require("naughty")

local helpers = require "helpers"

-- {{{ Variable definitions
local config = require "config"
local modkey = config.modkey
-- }}}

-- {{{ Layouts menu
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
}

-- {{{ flexmenu
local menu_items = {
    -- apps
    { "gvim", 'gvim' },
    { "pms", helpers.run_in_terminal_fn("pms") },
    { "mutt", helpers.run_in_terminal_fn("mutt") },
    { "midnight", config.alt_terminal ..  " -e dash -c 'sleep 0.1 ; mc'" },
    { "run", {
        { "run_in_term", helpers.run_in_terminal },
        { "run_or_raise", helpers.run_or_raise_menu },
    }},
    { "awesome", {
        { "restart", awesome.restart },
        { "quit", awesome.quit },
        { "themes", helpers.create_theme_menu() },
        { "layouts", helpers.create_layouts_menu(layouts) },
    }},
    { "redshift", {
       { "toggle day/night", "day_night.sh" },
       { "night", 'redshift -O 3700K' },
       { "day", 'redshift -x' },
    }},
    { "power", {
        { "sleep", 'gksudo pm-suspend' },
        { "halt", 'gksudo -- shutdown -h now' },
        { "reboot", 'gksudo -- shutdown -r now' }
    }},
    { "screens", helpers.create_screen_layouts_menu() }
}


local flexmenu = require("flexmenu")
flexmenu.init(menu_items, helpers.dmenu_opts, awful.util.spawn)
-- }}}


-- {{{ Tags
-- layouts count from 1

local function create_tags()
    local tags = {}
    local tmp_tags = {
        names = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
        layout = {
            awful.layout.suit.tile.left,
            awful.layout.suit.max,
            awful.layout.suit.max,
            awful.layout.suit.max,
            awful.layout.suit.max,
            awful.layout.suit.max,
            awful.layout.suit.max,
            awful.layout.suit.max,
            awful.layout.suit.tile.right,
            awful.layout.suit.tile.right
        }
    }

    for s = 1, screen.count() do
        tags[s] = awful.tag(tmp_tags.names, s, tmp_tags.layout)
    end
    return tags
end

local tags = create_tags()

-- }}}
-- {{{ panel
local mywidgets = require "widgets"
local panel = {}
local mylayoutbox = {}

local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({}, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
)

local mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({}, 1, function(c)
            if not c:isvisible() then
                awful.tag.viewonly(c:tags()[1])
            end
            awful.client.focus = c
            c:raise()
        end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
        if awful.client.focus then awful.client.focus:raise() end
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
        if awful.client.focus then awful.client.focus:raise() end
    end)
)

local function mysystray(s)
    if s == 1 then
        return widget({ type = "systray" })
    else
        return widget( { type = "textbox" })
    end
end

-- Create a wibox for each screen and add it
for s = 1, screen.count() do
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(
        awful.util.table.join(
            awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
            awful.button({}, 3, function() awful.layout.inc(layouts, -1) end)
        )
    )

    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    mytasklist[s] = awful.widget.tasklist(
        function(c)
            return awful.widget.tasklist.label.currenttags(c, s)
        end,
        mytasklist.buttons)

    --
    -- Create the wibox
    --
    panel[s] = awful.wibox({ position = config.panel_position, screen = s })
    -- Add widgets to the wibox - order matters
    panel[s].widgets = {
        {
            mytaglist[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mywidgets.datewidget, mywidgets.dateicon, mywidgets.separator,
        mywidgets.loadwidget, mywidgets.thermalwidget, mywidgets.cpuicon, mywidgets.separator,
        mywidgets.volwidget, mywidgets.volicon, mywidgets.separator,
        mywidgets.batwidget, mywidgets.baticon, mywidgets.separator,
        mysystray(s),
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
    panel[s].screen = s
end
-- }}}

local layouts_short =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile.right,
    awful.layout.suit.max,
}
-- {{{ Key bindings
local globalkeys = awful.util.table.join(
    awful.key({ modkey, }, "q", function() awful.screen.focus_relative(1) end),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore),
    awful.key({ modkey, }, "e", awful.tag.viewnext),
    awful.key({ modkey, }, "w", awful.tag.viewprev),

    awful.key({ modkey, }, "a", function() awful.layout.inc(layouts_short, 1) end),
    awful.key({ modkey, }, "j", function()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey, }, "k", function()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end),
    awful.key({ modkey }, "o", awful.client.movetoscreen),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey }, "b", function()
        panel[mouse.screen].visible = not panel[mouse.screen].visible
    end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "q", awesome.quit),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incmwfact(0.1) end),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incmwfact(-0.1) end),

    awful.key({ modkey, }, "Return", function() awful.util.spawn(config.terminal) end),
    awful.key({ modkey, "Mod1" }, "Return", function() awful.util.spawn(config.alt_terminal) end),
    awful.key({ modkey, "Control" }, "Return", function() awful.util.spawn(config.terminal .. " -e tmux") end),

    awful.key({ modkey }, "r", helpers.run_or_raise_menu),
    awful.key({ modkey }, "t", helpers.run_in_terminal),
    awful.key({ modkey }, "space", flexmenu.show_menu),

    awful.key({ modkey }, "y", helpers.switchapp),

    -- Not related to window mgmt
    awful.key({ "Control" }, ",", function() awful.util.spawn("mpc --quiet volume -5") end),
    awful.key({ "Control" }, ".", function() awful.util.spawn("mpc --quiet volume +5") end),
    awful.key({ "Control" }, "\\", function() awful.util.spawn("mpc --quiet toggle") end),
    awful.key({ "Control" }, "'", function() awful.util.spawn("mpc --quiet next") end),
    awful.key({ "Control" }, ";", function() awful.util.spawn("mpc --quiet prev") end),
    awful.key({ "Control" }, "/", function() awful.util.spawn("amixer set " .. config.mixer .. " toggle") end),
    awful.key({ modkey }, "l", function() awful.util.spawn("xflock4") end),
    awful.key({}, "#135", function() awful.util.spawn("xdotool click 2") end)
)

if helpers.file_exists('/usr/bin/toshiba-brightness.sh') then
    local newkeys = awful.util.table.join(
        awful.key({ modkey }, "Down", function() awful.util.spawn("sudo toshiba-brightness.sh dec") end),
        awful.key({ modkey }, "Up", function() awful.util.spawn("sudo toshiba-brightness.sh inc") end)
        )
    globalkeys = awful.util.table.join(globalkeys, newkeys)
end


local function focus_tag(tag)
    awful.tag.viewonly(tag)
    awful.screen.focus(tag.screen)
end

-- m101 - > moves client to the first tag of the first screen
-- s204 - > switches to fourth tag of the second screen
local function parse_tags_cmd(stack)
    local action = stack[1]
    local screen = tags[tonumber(stack[2])]
    local tag_no = tonumber(stack[3]..stack[4])
    local tag = screen[tag_no]
    if screen == nil or tag == nil then return end
    if action == "m" then
        awful.client.movetotag(tag)
        focus_tag(tag)
    elseif action == "s" then
        focus_tag(tag)
    else
        print("Invalid action " .. action)
        return
    end
end

local globalkeys = awful.util.table.join(
    globalkeys,
    awful.key({ modkey, "Shift"}, ";", function(c)
        local _stack = {}
        local _iter = 1
        keygrabber.run(
            function(mod, key, event)
                if _iter < 5 and event == "press" then
                    if _iter == 1 and not (key == "s" or key == "m") then
                        return false
                    end
                    if _iter > 1 and (tonumber(key) == nil) then
                        return false
                    end
                    _stack[_iter] = key
                    _iter = _iter + 1
                    naughty.notify(
                            { text = key,
                              screen = mouse.screen,
                              timeout = 2
                            })
                end
                if _iter > 4 then
                    parse_tags_cmd(_stack)
                    return false
                end
                return true
            end)
    end)
    )
-- First screen
local s = 1

for j, tag in ipairs(tags[s]) do
    if j <= 9 then
        globalkeys = awful.util.table.join(
            globalkeys,
            awful.key({ modkey }, j,
                function()
                    focus_tag(tag)
                end),
            awful.key({ modkey, "Shift" }, j,
                function()
                    if awful.client.focus then
                        awful.client.movetotag(tag)
                        focus_tag(tag)
                    end
                end))
    end
end

if tags[2] ~= nil then
    for j, tag in ipairs(tags[2]) do
        if j <= 9 then
            globalkeys = awful.util.table.join(
                globalkeys,
                awful.key({ modkey, "Mod1" }, j,
                    function()
                        focus_tag(tag)
                    end),
                awful.key({ modkey, "Mod1", "Shift" }, j,
                    function()
                        if awful.client.focus then
                            awful.client.movetotag(tag)
                            focus_tag(tag)
                        end
                    end))
        end
    end
end

root.keys(globalkeys)

local clientbuttons = awful.util.table.join(
    awful.button({}, 1, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

local clientkeys = awful.util.table.join(
    awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end),
    awful.key({ modkey, }, "m",
        function(c)
            c.screen = mouse.screen
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical = not c.maximized_vertical
        end),
    awful.key({ modkey, "Shift" }, "m",
        function(c)
            c.screen = mouse.screen
            c.maximized_vertical = not c.maximized_vertical
        end)
     )

-- }}}

-- {{{ Rules
--
awful_rules.rules = {{
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = true,
            size_hints_honor = false,
            keys = clientkeys,
            buttons = clientbuttons
        }
    },
    {
        rule = { class = "Firefox" },
        properties = { tag = tags[s][4] }
    },
    {
        rule = { class = "Chromium" },
        properties = { tag = tags[s][6] }
    },
    {
        rule = { class = "Pidgin" },
        properties = { tag = tags[s][7] }
    },
    {
        rule = { class = "Pidgin", role = "buddy_list" },
        properties = { floating = true },
        callback = function(c)
            local w = screen[c.screen].workarea.width
            local h = screen[c.screen].workarea.height
            c:geometry({ width = 0.3 * w, height = h })
            c.x = 0
            c.y = 19
        end
    },
    {
        rule = { class = "Pidgin", role = "conversation" },
        callback = function(c)
            local w = screen[c.screen].workarea.width
            local h = screen[c.screen].workarea.height
            awful.client.setslave(c)
            c:struts({ left = 0.3 * w })
        end
    },
    {
        rule = { class = "Skype" },
        properties = { tag = tags[s][7], floating = true }
    },
    {
        rule = { name = "Mozilla Thunderbird" },
        callback = function(c)
            c.screen = mouse.screen
            c:tags({tags[s][9]})
            c.floating = true
        end
    },
    {
        rule = { class = "Transmission" },
        properties = { tag = tags[s][9] }
    },
    {
        rule = { class = "Spotify" },
        properties = { tag = tags[s][10], floating = true }
    },
    {
        rule = { name = "IntelliJ" },
        properties = { tag = tags[s][3], floating = true }
    },
    {
        rule = { name = "PyCharm" },
        callback = function(c)
            c.screen = mouse.screen
            c:tags({tags[s][3]})
            c.floating = true
        end
    },
    {
        rule = { name = "Eclipse" },
        properties = { tag = tags[s][3] }
    },
    { rule = { class = "MPlayer" }, properties = { floating = true } },
    { rule = { class = "Gimp" }, properties = { floating = true } },
    { rule = { class = "pinentry" }, properties = { floating = true } },
    { rule = { class = "Qalculate" }, properties = { floating = true } },
    { rule = { class = "Krusader" }, properties = { floating = true } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function(c, startup)
-- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        -- if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        --         and awful.client.focus.filter(c) then
        --     client.focus = c
        -- end
        client.focus = c
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autostart
helpers.run_once("xscreensaver", "-no-splash")
helpers.kill_at_exit("xscreensaver")

helpers.run_once("dropbox", "start -i")
awesome.add_signal("exit", function()
    awful.util.spawn("dropbox stop")
end)

helpers.run_once("mpd")
helpers.run_once("parcellite")
helpers.kill_at_exit("parcellite")

helpers.run_once("redshift.sh")
helpers.kill_at_exit("redshift.sh")

helpers.run_once("awsetbg", "-f -r " .. config.userhome .. "/Wallpapers")
helpers.run_once("change-wallpaper.sh")
helpers.kill_at_exit("change-wallpaper.sh")

awful.util.spawn_with_shell("set-touchpad")
-- }}}

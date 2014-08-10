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


-- {{{ Themes menu
theme_menu = {}

function theme_load(theme)
    awful.util.spawn("ln -sfn " .. confdir .. "/themes/" .. theme .. " " .. confdir .. "/themes/current")
    awesome.restart()
end

function theme_menu_create()
    local cmd = "ls -1 " .. confdir .. "/themes/"
    local f = io.popen(cmd)

    for l in f:lines() do
        local item = { l, function() theme_load(l) end }
        table.insert(theme_menu, item)
    end

    f:close()
end

theme_menu_create()
-- }}}
-- {{{ Layouts menu
layouts =
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
layouts_menu = {}
function layouts_menu_create()
    for i, l in ipairs(layouts) do
        local fn = function()
        -- set layout for current tag
            awful.layout.set(l)
        end
        local name = awful.layout.getname(l)
        local item = { name, fn }
        table.insert(layouts_menu, item)
    end
end

layouts_menu_create()

-- {{{ flexmenu
local menu_items = {
    { "run_in_term", helpers.run_in_terminal },
    { "run_or_raise", helpers.run_or_raise_menu },
    {
        "awesome", {
        { "restart", awesome.restart },
        { "quit", awesome.quit },
        { "themes", theme_menu },
        { "layouts", layouts_menu },
    }
    },
    { "gvim", 'gvim' },
    { "pms", config.alt_terminal .. " -e pms"  },
    { "midnight", config.alt_terminal .. " -e dash -c 'sleep 0.1 ; mc'" },
    { "toggle day/night", "day_night.sh" },
    { "redshift", {
       { "night", 'redshift -O 3700K' },
       { "day", 'redshift -x' },
    } 
    },
    { "layout max", function () awful.layout.set(awful.layout.suit.max) end }
}

flexmenu = require("flexmenu")
flexmenu.init(menu_items, helpers.dmenu_opts, awful.util.spawn)
-- }}}


-- {{{ Tags
-- layouts count from 1
tags = {
    names = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
    layout = {
        awful.layout.suit.max,
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
    tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- }}}
-- {{{ panel
local mywidgets = require "widgets"
local top_panel = {}
local bottom_panel = {}
local mypromptbox = {}
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

local mysystray = widget({ type = "systray" })

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
    top_panel[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    top_panel[s].widgets = {
        {
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mywidgets.datewidget, mywidgets.dateicon, mywidgets.separator,
        mywidgets.loadwidget, mywidgets.thermalwidget, mywidgets.cpuicon, mywidgets.separator,
        mywidgets.volwidget, mywidgets.volicon, mywidgets.separator,
        mywidgets.batwidget, mywidgets.baticon, mywidgets.separator,
        mysystray,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
    top_panel[s].screen = s
end
-- }}}

local layouts_short =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile.right,
    awful.layout.suit.max,
}
-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey, }, "Left", awful.tag.viewprev),
    awful.key({ modkey, }, "Right", awful.tag.viewnext),
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
    awful.key({ modkey, "Shift" }, "o", function() 
        local count = 0
        local _tag = awful.tag.selected()
        local _screen = 2 -- hack
        if mouse.screen == 2 then
            _screen = 1
        end
        local _newtag = tags[_screen][_tag.name]
        print(_newtag)
        print(_tag)
        for _, c in pairs(_tag:clients()) do
            if client.class ~= c.class then
                awful.client.movetoscreen(c)
                awful.client.movetotag(_newtag)
            end
        end
    end),
    awful.key({ modkey }, "F1",     function () awful.screen.focus(1) end),
    awful.key({ modkey }, "F2",     function () awful.screen.focus(2) end),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey }, "b", function()
        top_panel[mouse.screen].visible = not top_panel[mouse.screen].visible
    end),
    awful.key({ modkey, }, "Return", function() awful.util.spawn(config.terminal) end),
    awful.key({ modkey, "Mod1" }, "Return", function() awful.util.spawn(config.alt_terminal) end),
    awful.key({ modkey, "Control" }, "Return", function() awful.util.spawn(config.terminal .. " -e tmux") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "q", awesome.quit),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey }, "r", helpers.run_or_raise_menu),
    awful.key({ modkey }, "t", helpers.run_in_terminal),
    awful.key({ modkey }, "space", flexmenu.show_menu),
    awful.key({ modkey }, "q", helpers.simpleswitcher),
    -- Not related to window mgmt
    awful.key({ "Control" }, ",", function() awful.util.spawn("mpc --quiet volume -5") end),
    awful.key({ "Control" }, ".", function() awful.util.spawn("mpc --quiet volume +5") end),
    awful.key({ "Control" }, "\\", function() awful.util.spawn("mpc --quiet toggle") end),
    awful.key({ "Control" }, "'", function() awful.util.spawn("mpc --quiet next") end),
    awful.key({ "Control" }, ";", function() awful.util.spawn("mpc --quiet prev") end),
    awful.key({ "Control" }, "/", function() awful.util.spawn("amixer set " .. config.mixer .. " toggle") end),
    awful.key({ modkey }, "l", function() awful.util.spawn("xflock4") end),
    awful.key({}, "#135", function() awful.util.spawn("xdotool click 2") end))

if helpers.file_exists('/usr/bin/toshiba-brightness.sh') then
    local newkeys = awful.util.table.join(
        awful.key({ modkey }, "Down", function() awful.util.spawn("sudo toshiba-brightness.sh dec") end),
        awful.key({ modkey }, "Up", function() awful.util.spawn("sudo toshiba-brightness.sh inc") end)
        )
    globalkeys = awful.util.table.join(globalkeys, newkeys)
end

for i = 1, 9 do
    globalkeys = awful.util.table.join(
        globalkeys,
        awful.key({ modkey }, i,
            function()
                local s = mouse.screen
                local t = tags[s][i]
                awful.tag.viewonly(t)

            end),
        awful.key({ modkey, "Shift" }, i,
            function()
                if awful.client.focus then
                    local s = mouse.screen
                    local t = tags[s][i]
                    awful.client.movetotag(t)
                    awful.tag.viewonly(t)
                end
            end)
        )
end

root.keys(globalkeys)

clientbuttons = awful.util.table.join(
    awful.button({}, 1, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical = not c.maximized_vertical
        end),
    awful.key({ modkey, "Shift" }, "m",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
        end)
     )

-- }}}

-- {{{ Rules
local s = 1;
--
awful_rules.rules = {
    {
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
        properties = { tag = tags[s][9] }
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
        properties = { tag = tags[s][3], floating = true }
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
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                and awful.client.focus.filter(c) then
            client.focus = c
        end
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
-- run_once("xscreensaver", "-no-splash")
-- run_once("dropbox", "start -i", nil)
-- run_once("mpd")
-- run_once("parcellite")
-- run_once("mail-notification", nil, nil)
-- run_once("conky", "-c .conky/std.conf", nil)
-- run_once("awsetbg", "-f -r " .. config.userhome .. "/Wallpapers", nil)
-- run_once("change-wallpaper.sh")
-- run_once("redshift.sh")
-- awful.util.spawn_with_shell("set-touchpad")
-- }}}

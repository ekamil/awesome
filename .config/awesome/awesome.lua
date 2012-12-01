require("awful")
require("awful.rules")
require("eminent")
require("awful.autofocus")
require("vicious")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- {{{ helpers 
function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end

function is_on_path(name)
    local f = os.execute("which " .. name .. " > /dev/null")
    if f ~= nil then
        if f == 0 then
            return true
        end
    end
    return false
end
-- }}}

-- {{{ beautiful
cfg_path = awful.util.getdir("config")

beautiful.init(cfg_path .. "/themes/current/theme.lua")
-- }}}

-- {{{ Variable definitions
editor = os.getenv("EDITOR") or "editor"
userhome = os.getenv("HOME")
shell = os.getenv("SHELL")
terminal = "xfce4-terminal -e " .. shell
alt_terminal = userhome .. "/.local/bin/urxvt-zenburn.sh"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
dmenu_opts = "-b -nb '" .. beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. "' -sb '#955'" .. " -fn '" .. beautiful.font .. "'"

if is_on_path("yeganesh") then
    dmenu_path = "dmenu_path | yeganesh -p default -- " .. dmenu_opts
else
    dmenu_path = "dmenu_path | dmenu " .. dmenu_opts
end
--
config = {}
if file_exists('/sys/class/power_supply/BAT1/status') then
    config.bat = "BAT1"
else
    config.bat = "BAT0"
end

if file_exists('/usr/bin/toshiba-brightness.sh') then
    config.toshiba = true
else
    config.toshiba = false
end

config.mixer = "Master"


-- }}}

-- {{{ Run sth helpers 
function run_or_raise(command)
    -- Check throught the clients if the class match the command
    local lower_command = string.lower(command)
    for k, c in pairs(client.get()) do
        local class = string.lower(c.class)
        if string.match(class, lower_command) then
            for i, v in ipairs(c:tags()) do
                awful.tag.viewonly(v)
                c:raise()
                c.minimized = false
                return
            end
        end
    end
    awful.util.spawn(command)
end

function run_or_raise_menu()
    local f_reader = io.popen(dmenu_path)
    local command = assert(f_reader:read('*a'))
    f_reader:close()
    if command == "" then return end
    run_or_raise(command)
end

function simpleswitcher()
    awful.util.spawn("simpleswitcher -now -bg '" .. beautiful.bg_normal ..
            "' -fg '" .. beautiful.fg_normal ..
            "' -fn '" .. beautiful.font .. "'")
end

function run_in_terminal()
    local f_reader = io.popen(dmenu_path)
    local command = assert(f_reader:read('*a'))
    f_reader:close()
    if command == "" then return end
    command = alt_terminal .. ' -e ' .. command
    awful.util.spawn(command)
end

function check_for_terminal(command)
    if command:sub(1, 1) == ":" then
        command = alt_terminal .. ' -e ' .. command:sub(2)
    end
    awful.util.spawn(command)
end

function run_in_terminal_fn(command)
    local function internal()
        command = alt_terminal .. ' -e ' .. command
        awful.util.spawn(command)
    end

    return internal
end

function clean_for_completion(command, cur_pos, ncomp, shell)
    local term = false
    if command:sub(1, 1) == ":" then
        term = true
        command = command:sub(2)
        cur_pos = cur_pos - 1
    end
    command, cur_pos = awful.completion.shell(command, cur_pos, ncomp, shell)
    if term == true then
        command = ':' .. command
        cur_pos = cur_pos + 1
    end
    return command, cur_pos
end


-- }}}

-- {{{ Themes menu
mythememenu = {}

function theme_load(theme)
    awful.util.spawn("ln -sfn " .. cfg_path .. "/themes/" .. theme .. " " .. cfg_path .. "/themes/current")
    awesome.restart()
end

function theme_menu()
    local cmd = "ls -1 " .. cfg_path .. "/themes/"
    local f = io.popen(cmd)

    for l in f:lines() do
        local item = { l, function() theme_load(l) end }
        table.insert(mythememenu, item)
    end

    f:close()
end

theme_menu()
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
-- mythememenu {{theme_name, theme_load},}
-- layouts_menu {{layout_name, layout_function},}
local menu_items = {
    { "RunTerm", run_in_terminal },
    { "RunOrRaise", run_or_raise },
    {
        "awesome", {
        { "restart", awesome.restart },
        { "quit", awesome.quit },
        { "themes", mythememenu },
        { "layouts", layouts_menu },
    }
    },
    { "GVim", 'gvim' },
    { "urxvt", alt_terminal },
    { "KeePass", run_in_terminal_fn("fatman_keepass.sh") },
    { "firefox", run_in_terminal_fn("firefox5") },
    { "midnight", alt_terminal .. " -e dash -c 'sleep 0.1 ; mc'" },
    { "toggle day/night", "day_night.sh" },
    { "calc", "xclip -selection clipboard -o | bc | xclip -selection clipboard -i" },
}

require("flexmenu")
flexmenu.init(menu_items, dmenu_opts, awful.util.spawn)
-- }}}


-- {{{ Tags
-- layouts count from 1
tags = {
    names = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
    layout = {
        awful.layout.suit.max,
        awful.layout.suit.tile,
        awful.layout.suit.max,
        awful.layout.suit.tile,
        awful.layout.suit.tile,
        awful.layout.suit.tile,
        awful.layout.suit.tile,
        awful.layout.suit.max,
        awful.layout.suit.tile.left
    }
}

local s = 1
tags[s] = awful.tag(tags.names, s, tags.layout)

-- }}}
-- {{{ panel
require("widgets")
top_panel = {}
bottom_panel = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(awful.button({}, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev))
mytasklist = {}
mytasklist.buttons = awful.util.table.join(awful.button({}, 1, function(c)
    if not c:isvisible() then
        awful.tag.viewonly(c:tags()[1])
    end
    client.focus = c
    c:raise()
end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end))

mysystray = widget({ type = "systray" })
-- Create a wibox for each screen and add it
for s = 1, screen.count() do
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
        awful.button({}, 3, function() awful.layout.inc(layouts, -1) end)))
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    mytasklist[s] = awful.widget.tasklist(function(c)
        return awful.widget.tasklist.label.currenttags(c, s)
    end, mytasklist.buttons)

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
        datewidget, dateicon, separator,
        loadwidget, thermalwidget, cpuicon, separator,
        volwidget, volicon, separator,
        batwidget, baticon, separator,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
    top_panel[s].screen = s
end
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(awful.key({ modkey, }, "Left", awful.tag.viewprev),
    awful.key({ modkey, }, "Right", awful.tag.viewnext),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore),
    awful.key({ modkey, }, "e", awful.tag.viewnext),
    awful.key({ modkey, }, "w", awful.tag.viewprev),

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
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey }, "b", function()
        top_panel[mouse.screen].visible = not top_panel[mouse.screen].visible
    end),
    awful.key({ modkey, }, "Return", function() awful.util.spawn(terminal) end),
    awful.key({ modkey, "Mod1" }, "Return", function() awful.util.spawn(alt_terminal) end),
    awful.key({ modkey, "Control" }, "Return", function() awful.util.spawn(terminal .. " -e screen") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "q", awesome.quit),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey }, "r", run_or_raise_menu),
    awful.key({ modkey }, "space", flexmenu.show_menu),
    awful.key({ modkey }, "q", simpleswitcher),
    -- Custom
    awful.key({ "Control" }, ",", function() awful.util.spawn("mpc volume -5") end),
    awful.key({ "Control" }, ".", function() awful.util.spawn("mpc volume +5") end),
    awful.key({ "Control" }, "\\", function() awful.util.spawn("mpc toggle") end),
    awful.key({ "Control" }, "'", function() awful.util.spawn("mpc next") end),
    awful.key({ "Control" }, ";", function() awful.util.spawn("mpc prev") end),
    awful.key({ "Control" }, "/", function() awful.util.spawn("amixer set " .. config.mixer .. " toggle") end),
    awful.key({ modkey }, "l", function() awful.util.spawn("xflock4") end))

if config.toshiba then
    local newkeys = awful.util.table.join(awful.key({ modkey }, "Down", function() awful.util.spawn("sudo toshiba-brightness.sh dec") end),
        awful.key({ modkey }, "Up", function() awful.util.spawn("sudo toshiba-brightness.sh inc") end),
        awful.key({}, "#135", function() awful.util.spawn("xdotool click 2") end))
    globalkeys = awful.util.table.join(globalkeys, newkeys)
else
    local newkeys = awful.util.table.join(awful.key({}, "#135", function() awful.util.spawn("xdotool click 2") end))
    globalkeys = awful.util.table.join(globalkeys, newkeys)
end

for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, i,
            function()
                awful.tag.viewonly(tags[s][i])
            end))
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey, "Control" }, i,
            function()
                local t = tags[s][i]
                t.selected = not t.selected
            end))
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey, "Control", "Shift" }, i,
            function()
                if client.focus then
                    awful.client.toggletag(tags[s][i])
                end
            end))
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey, "Shift" }, i,
            function()
                if client.focus then
                    local t = tags[s][i]
                    awful.client.movetotag(t)
                    awful.tag.viewonly(t)
                end
            end))
end


clientbuttons = awful.util.table.join(awful.button({}, 1, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

clientkeys = awful.util.table.join(awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end),
    awful.key({ modkey, }, "m", function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical = not c.maximized_vertical
    end),
    awful.key({ modkey, "Shift" }, "m", function(c)
        c.maximized_vertical = not c.maximized_vertical
    end))

root.keys(globalkeys)
-- }}}

-- {{{ Rules
--
awful.rules.rules = {
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = true,
            keys = clientkeys,
            size_hints_honor = false,
            buttons = clientbuttons
        }
    },
    {
        rule = { class = "luakit" },
        properties = { tag = tags[s][2] }
    },
    {
        rule = { class = "Firefox" },
        properties = { tag = tags[s][3] }
    },
    {
        rule = { class = "Chromium" },
        properties = { tag = tags[s][4] }
    },
    {
        rule = { class = "Pidgin" },
        properties = { tag = tags[s][8] }
    },
    {
        rule = { class = "Pidgin", role = "buddy_list" },
        properties = { floating = true, x = 0, y = 0 },
        callback = function(c)
            local w = screen[c.screen].workarea.width
            local h = screen[c.screen].workarea.height
            c:geometry({ width = 0.3 * w, height = h })
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
        rule = { class = "Skype", role = "MainWindow" },
        properties = { tag = tags[s][9], floating = true },
        callback = function(c)
            local w = screen[c.screen].workarea.width
            local h = screen[c.screen].workarea.height
            c:geometry({ width = 0.2 * w, height = h })
            c.x = 0
            c.y = 0
        end
    },
    {
        rule = { class = "Skype", role = "Chats" },
        properties = { floating = false },
        callback = function(c)
            local w = screen[c.screen].workarea.width
            local h = screen[c.screen].workarea.height
            awful.client.setslave(c)
            c:struts({ left = 0.2 * w })
        end
    },
    {
        rule = { class = "Skype", role = "CallWindow" },
        properties = { floating = false },
        callback = function(c)
            local w = screen[c.screen].workarea.width
            local h = screen[c.screen].workarea.height
            c:struts({ left = 0.2 * w })
        end
    },
    {
        rule = { class = "Deluge" },
        properties = { tag = tags[s][6] }
    },
    {
        rule = { name = "IntelliJ" },
        properties = { tag = tags[s][7] }
    },
    { rule = { class = "MPlayer" }, properties = { floating = true } },
    { rule = { class = "Gimp" }, properties = { floating = true } },
    { rule = { class = "pinentry" }, properties = { floating = true } },
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
function run_once(prg, arg_string, pname, screen)
    if not prg then
        do return nil end
    end
    if not pname then
        pname = prg
    end

    if not arg_string then
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")", screen)
    else
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. " " .. arg_string .. ")", screen)
    end
end

run_once("xscreensaver", "-no-splash")
run_once("dropbox", "start -i", nil)
run_once("mpd")
run_once("parcellite", nil, nil)
run_once("mail-notification", nil, nil)
awful.util.spawn_with_shell("sleep 40 && awsetbg -f -r Wallpapers")
awful.util.spawn_with_shell("set-touchpad")
-- }}}

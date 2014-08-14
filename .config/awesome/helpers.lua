local config = require "config"
local helpers = {}
-- {{{ helpers 
local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end
helpers.file_exists = file_exists

local function is_on_path(name)
    local f = os.execute("which " .. name .. " > /dev/null")
    if f ~= nil then
        if f == 0 then
            return true
        end
    end
    return false
end
helpers.is_on_path = is_on_path
-- }}}

-- {{{ dmenu
local function get_dmenu()
    if is_on_path("yeganesh") then
        return "dmenu_path | yeganesh -p default -- " .. config.dmenu_opts
    else
        return "dmenu_path | dmenu " .. config.dmenu_opts
    end
end
dmenu = get_dmenu()
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
helpers.run_or_raise = run_or_raise

function helpers.run_or_raise_menu()
    local f_reader = io.popen(dmenu)
    local command = assert(f_reader:read('*a'))
    f_reader:close()
    if command == "" then return end
    run_or_raise(command)
end

function helpers.run_in_terminal()
    local f_reader = io.popen(dmenu)
    local command = assert(f_reader:read('*a'))
    f_reader:close()
    if command == "" then return end
    command = config.alt_terminal .. ' -e ' .. command
    awful.util.spawn(command)
end

function helpers.run_in_terminal_fn(command)
    return config.alt_terminal .. ' -e ' .. command
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

-- {{{ Autostart
function run_once(prg, arg_string, persistent)
    if not prg then return nil end
    if persistent == nil then persistent=false end

    pid = nil
    if not arg_string then
        pid = awful.util.spawn_with_shell("pgrep -u $USER '" .. prg .. "' || (" .. prg .. ")")
    else
        pid = awful.util.spawn_with_shell("pgrep -u $USER '" .. prg .. "' || (" .. prg .. " " .. arg_string .. ")")
    end
    if pid ~= nil and not persistent then
        print("Will kill " .. prg .. " pid: " .. pid)
        awesome.add_signal("exit", function()
            awful.util.spawn_with_shell("kill " .. pid)
        end)
    end
end
helpers.run_once = run_once

local function kill_at_exit(prg)
    if not prg then return nil end
    awesome.add_signal("exit", function()
        awful.util.spawn_with_shell("pkill -fu $USER " .. prg)
    end)
end
helpers.kill_at_exit = kill_at_exit

-- }}}

function helpers.switchapp()
    local awful= require("awful")
    local client = client

    local allclients = client.get()
    clientsline = ""
    for _,c in ipairs(allclients) do
        cname = c.name
        if c:tags() then
            cname = c:tags()[1].screen .. "/" .. c:tags()[1].name .. " - " .. cname
        end
        clientsline = clientsline .. cname .. "\n"
    end
    selected = awful.util.pread("echo '".. clientsline .."' | dmenu -l 10 " .. config.dmenu_opts)
    for _,c in ipairs(allclients) do
        a = c:tags()[1].name .. " - " .. c.name
        if a == selected:gsub("\n", "") then
            for i, v in ipairs(c:tags()) do
            awful.tag.viewonly(v)
            client.focus = c
            c:raise()
            c.minimized = false
            return
            end
        end
    end
end

local function load_screen_layout(layout)
    -- switch layout as in screenlayouts and restart awesome
    if layout == nil then return nil end
    local exec_file = confdir .. '/layouts/' .. layout .. '.sh'
    print(exec_file)
    if file_exists(exec_file) then
        awful.util.spawn_with_shell(exec_file)
        awesome.restart()
    end
end
helpers.load_screen_layout = load_screen_layout

local function create_screen_layouts_menu()
    local cmd = "ls -1 " .. confdir .. "/layouts/"
    local f = io.popen(cmd)
    local menu = {}

    for l in f:lines() do
        l = string.sub(l, 1, -4)
        local item = { l, function() load_screen_layout(l) end }
        table.insert(menu, item)
    end

    f:close()
    return menu
end
helpers.create_screen_layouts_menu = create_screen_layouts_menu

-------------

-- {{{ Themes menu

local function create_theme_menu()
    local cmd = "ls -1 " .. confdir .. "/themes/"
    local f = io.popen(cmd)
    local menu = {}

    local function theme_load(theme)
        awful.util.spawn("ln -sfn " .. confdir .. "/themes/" .. theme .. " " .. confdir .. "/themes/current")
        awesome.restart()
    end

    for l in f:lines() do
        local item = { l, function() theme_load(l) end }
        table.insert(menu, item)
    end

    f:close()
    return menu
end
helpers.create_theme_menu = create_theme_menu
-- }}}

local function create_layouts_menu(layouts)
    local menu = {}
    for i, l in ipairs(layouts) do
        local fn = function()
        -- set layout for current tag
            awful.layout.set(l)
        end
        local name = awful.layout.getname(l)
        local item = { name, fn }
        table.insert(menu, item)
    end
    return menu
end
helpers.create_layouts_menu = create_layouts_menu

return helpers

local config = require "config"
local helpers = {}
-- {{{ helpers 
function helpers.file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end

local function is_on_path(name)
    local f = os.execute("which " .. name .. " > /dev/null")
    if f ~= nil then
        if f == 0 then
            return true
        end
    end
    return false
end
-- }}}

-- {{{ dmenu
local dmenu_opts = "-i -b -nb '" .. beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. "' -sb '#955'"
helpers.dmenu_opts = dmenu_opts

local function get_dmenu()
    if is_on_path("yeganesh") then
        return "dmenu_path | yeganesh -p default -- " .. dmenu_opts
    else
        return "dmenu_path | dmenu " .. dmenu_opts
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

function helpers.simpleswitcher()
    awful.util.spawn("simpleswitcher -now -bg '" .. beautiful.bg_normal ..
            "' -fg '" .. beautiful.fg_normal ..
            "' -fn '" .. beautiful.font .. "'")
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
function helpers.run_once(prg, arg_string, pname, screen)
    if not prg then
        do return nil end
    end
    if not pname then
        pname = prg
    end

    if not arg_string then
        awful.util.spawn_with_shell("pgrep -u $USER '" .. pname .. "' || (" .. prg .. ")")
    else
        awful.util.spawn_with_shell("pgrep -u $USER '" .. pname .. "' || (" .. prg .. " " .. arg_string .. ")")
    end
end
-- }}}

function helpers.switchapp()
    local awful= require("awful")
    local client = client

    local allclients = client.get()
    clientsline = ""
    for _,c in ipairs(allclients) do
    clientsline = clientsline .. c:tags()[1].name .. " - " .. c.name .. "\n"
    end
    selected = awful.util.pread("echo '".. clientsline .."' | dmenu -l 10 " .. dmenu_opts)
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


return helpers

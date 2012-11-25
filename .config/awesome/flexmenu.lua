#!/usr/bin/env lua
--[[
Dmenu wrapper with nested menus.
Author: Kamil Essekkat <kamil@essekkat.pl>
--]]
local P = {}


local function init(menu_items, dmenu_opts)
    P.menu_items = menu_items
    P.dmenu_opts = dmenu_opts
end


local function print_tab(t, p, d)
    -- t (table): menu , p (string): path, d(number): max depth
    local cur_depth = 0
    for title, item in pairs(t) do
        if (p ~= nil and p ~= '') then title = p .. '/' .. title end
        if type(item) ~= 'table' then
            local s = string.format("%s => %s", title, item)
            print(s)
        else
            cur_depth = cur_depth + 1
            if cur_depth <= d then 
                print_tab(item, title, d-cur_depth) 
            else
                local s = string.format("%s => submenu", title)
                print(s)
            end
        end
    end
end


local function call_dmenu(t)
    -- t (table): list of items
    local function internal(t)
        local n = os.tmpname()
        assert(n, "Cannot create temp file") 
        local dm = io.popen('dmenu ' .. P.dmenu_opts .. ' > ' .. n , "w")
        assert(dm, "Cannot run dmenu") 
        for k, v in ipairs(t) do 
            dm:write(v .. '\n') 
        end
        dm:close()
        local rf = io.open(n)
        assert(rf, "Cannot read temp file") 
        local rval = rf:read("*a")
        rf:close()
        os.remove(n)
        return rval
    end
    ok, rval = pcall(internal, t)
    if ok then
        -- if empty string then the choice was cancelled
        if rval == '' then return nil end
        return rval
    else
        return nil
    end
end


local function choose(t)
    local choices = {}
    for k, v in pairs(t) do
        table.insert(choices, k)
    end
    local selected = call_dmenu(choices)
    local choices = {}
    if selected ~= nil then
        return t[selected]
    else
        return nil
    end
end


local function choose_mlevel(t)
    local selected = nil
    local t_ = t
    while not selected or type(selected) == 'table' do
        selected = choose(t_)
        if selected == nil then return nil end
        t_ = selected
    end
    return selected
end

local function show_menu()
    cmd = choose_mlevel(P.menu_items)
    if cmd ~= nil then
        if type(cmd) == 'string' then
            io.popen(cmd)
        elseif type(cmd) == 'function' then
            cmd()
        else
            print("NotImplemented")
        end
    end
end


flexmenu = {
    show_menu = show_menu,
    init = init,
}
return flexmenu

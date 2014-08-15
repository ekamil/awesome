#!/usr/bin/env lua

-- Check for mail in maildirs.
-- Rewrite in lua of http://mailcheck.sourceforge.net/
version = '1.0'
local lfs = require("lfs")

-- globals
globals = {}
globals.unread = 0
globals.new = 0


local function read_config(configfile)
    local maildirs = {}
    local f = io.open(configfile)
    if f == nil then
        print( "Invalid config " .. configfile )
        return nil
    end
    while true do
        local line = f:read("*line")
        if line == nil then break end
        if lfs.attributes(line, 'mode') == 'directory' then
            table.insert(maildirs, line)
        else
            print("invalid line: " .. line)
        end
    end
    f:close()
    return maildirs
end


local function is_unread(entry)
    -- entry like 1390_1.890.klap,U\=749,FMD5\=375:2,S
    local flags = entry:sub( entry:find(":"), nil )
    if flags:find("S") == nil then 
        return 'unread'
    else
        return nil
    end
end


local function count_files(path)
    local cnt = 0
    for file in lfs.dir(path) do
        if file:find("=") ~= nil  then
            cnt = cnt + 1
        end
    end
    return cnt
end


local function count_unread(path)
    local cnt = 0
    for file in lfs.dir(path) do
        if file:find(":") ~= nil  then
            if is_unread(file) ~= nil then
                cnt = cnt + 1
            end
        end
    end
    return cnt
end


local function pj(...)
    sep = '/'
    result = ''
    for i, v in ipairs(arg) do
        if i == 1 then
            result = tostring(v)
        else
            result = result .. sep .. tostring(v)
        end
    end
    return result
end


function main()
    local configfile = pj(os.getenv("HOME"), '.mailcheckrc')

    local maildirs = {}
    for k, pth in pairs(read_config(configfile)) do
        local _unread = count_unread( pj(pth, 'cur') )
        local _new = count_files( pj(pth, 'new') )

        globals.unread = globals.unread + _unread
        globals.new = globals.new + _new
        table.insert(maildirs, {name=pth, unread=_unread, new=_new})
    end
    local summary = string.format("%d new %d unread", globals.new, globals.unread)
    return summary, maildirs
end

function has_mail()
    local configfile = pj(os.getenv("HOME"), '.mailcheckrc')

    for k, pth in pairs(read_config(configfile)) do
        local _unread = count_unread( pj(pth, 'cur') )
        local _new = count_files( pj(pth, 'new') )
        if (_new + _unread) > 0 then
            return true
        end
    end
    return false
end

local mod = {}
mod.count_mail = main
mod.has_mail = has_mail
return mod

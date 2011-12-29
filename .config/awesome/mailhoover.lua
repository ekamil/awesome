local string = string
--local print = print
local tostring = tostring
local io = io
local table = table
local pairs = pairs
local capi = {
    mouse = mouse,
    screen = screen
}
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require('beautiful')
module("mailhoover")

local popup
local account_format = "<span color='" .. beautiful.fg_urgent .."'><b>%s</b></span>"
local dir_format = "<span color='" .. beautiful.fg_normal .."'><b>%s</b></span>"
local newmail_format = "<span color='" .. beautiful.fg_urgent .. "'>%s</span>"
local oldmail_format = "<span color='" .. beautiful.fg_focus .. "'>%s</span>"

function addToWidget(mywidget, maildirs, accountname)
  mywidget:add_signal('mouse::enter', function ()
        local info = read_maildirs(maildirs)
        popup = naughty.notify({
                title = string.format(account_format,accountname),
                text = info,
                timeout = 0,
                hover_timeout = 0.5,
                screen = capi.mouse.screen
        })
  end)
  mywidget:add_signal('mouse::leave', function () naughty.destroy(popup) end)
end

function read_maildirs(md)
    local info = ""
    local count = 0

    for i=1, #md do
        mdir = md[i]
        mails = {}
        -- Recursively find new messages
        local f = io.popen("find '"..mdir.."' -type f -wholename '*/new/*'")
        local counter = 0
        for line in f:lines() do 
            if counter < 5 then 
                table.insert(mails,format_mail(newmail_format,line)) 
            else
                table.insert(mails, "\n")
            end
            counter = counter + 1
        end
        f:close()
        counter = 0

        -- Recursively find "old" messages lacking the Seen flag
        local f = io.popen("find '"..mdir.."' -type f -regex '.*/cur/.*2,[^S]*$'")
        for line in f:lines() do 
            if counter < 5 then 
                table.insert(mails,format_mail(oldmail_format,line))
            else
                table.insert(mails, "\n")
            end
            counter = counter + 1
        end
        f:close()

        if #mails>0 then info = info .. string.format(dir_format,mdir) .. ':\n' end
        for m=1, #mails do
            info = info .. mails[m]
            if m >= 5 then 
                info = info .. "And " .. #mails - 5 .. " more\n"
                break 
            end
        end
    end
   return info
end

function format_mail(template,mailpath)
    mailfile = io.open(mailpath,"r")
    for line in mailfile:lines() do
       if line:find("^Subject:") then subject = string.match(line, "^Subject: (.*)%s?") end
       if line:find("^From:") then 
           from = string.match(line, "^From: (.*)") 
           from = string.gsub(from, "<.*>","")
       end
    end
    mailfile:close()
    return string.format(" %-30s %s\n", from, subject)
end

function get_maildirs_from_mailcheck ()
    local home = "/home/kamil/"
    local rcfpath = home .. ".mailcheckrc"
    local rcfile = io.open(rcfpath)
    maildirs = {}
    for line in rcfile:lines() do
        local newvalue = string.gsub(line, '$%(HOME%)', home, 1)
        table.insert(maildirs, newvalue) 
    end
    return maildirs
end


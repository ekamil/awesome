public = {}

local helpers = require "helpers"

local icons = {}
icons.dir = awful.util.getdir("config") .. "/themes/icons/"
icons.date = icons.dir .. "date.png"
icons.time = icons.dir .. "time.png"
icons.mpd = icons.dir .. "mpd.png"
icons.vol = icons.dir .. "vol.png"
icons.vol_mute = icons.dir .. "vol_mute.png"
icons.charging = icons.dir .. "bat_plus.png"
icons.sep = icons.dir .. "sep.png"
icons.uptime = icons.dir .. "uptime.png"
icons.batt_ac = icons.dir .. "ac.png"
icons.batt_bat1 = icons.dir .. "bat1.png"
icons.batt_bat2 = icons.dir .. "bat2.png"
icons.batt_bat3 = icons.dir .. "bat3.png"
icons.batt_bat4 = icons.dir .. "bat4.png"
icons.batt_bat5 = icons.dir .. "bat5.png"
icons.batt_bat6 = icons.dir .. "bat6.png"
icons.batt_bat7 = icons.dir .. "bat7.png"
icons.batt_bat8 = icons.dir .. "bat8.png"

icons.temp = icons.dir .. "temp_m.png"
icons.cpu = icons.dir .. "cpu.png"
icons.mem = icons.dir .. "mem.png"
icons.fs = icons.dir .. "disk.png"
icons.netio = icons.dir .. "netio-green.png"
icons.wifi = icons.dir .. "wifi_02.png"

icons.mail = icons.dir .. "mail.png"
icons.nomail = icons.dir .. "mail.png"

icons.awesome = awful.util.getdir("config") .. "/themes/current/awesome-icon.png"

local mytimes = {}
mytimes.baticon = 3
mytimes.batwidget = 4
mytimes.mpdwidget = 1
mytimes.vol = 1
mytimes.thermal = 7
mytimes.mem = 8
mytimes.hddt = 20
mytimes.cpu = 9
mytimes.net = 10
mytimes.wifi = 60
mytimes.io = 11
mytimes.fs = 12
mytimes.mail = 1
mytimes.uptime = 600
mytimes.date = 55


-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(icons.sep)

public.separator = separator
-- }}}

-- {{{ Date and time
dateicon = widget({ type = "imagebox" })
dateicon.image = image(icons.date)
public.dateicon = dateicon

date_format = "%a, %d %b %Y, week %V, %H:%M"

datewidget = widget({ type = "textbox" })
local calendar2 = require("calendar2")
calendar2.addCalendarToWidget(datewidget)

vicious.register(datewidget, vicious.widgets.date, date_format, mytimes.date)

public.datewidget = datewidget
-- }}}

-- {{{ Volume level

-- Icon widget
volicon = widget({ type = "imagebox" })
vicious.register(volicon, vicious.widgets.volume,
    function(widget, args)
        local mute
        mute = args[2]
        volicon.image = image(icons.vol)
        if mute == "♩" then
            volicon.image = image(icons.vol_mute)
        end
    end,
    mytimes.vol, helpers.volume.mixer)

public.volicon = volicon

-- Text Widget
volwidget = widget({ type = "textbox" })
-- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volwidget, vicious.widgets.volume, " $1%", mytimes.vol, helpers.volume.mixer)
-- Register buttons
volwidget:buttons(awful.util.table.join(
    awful.button({}, 1, helpers.volume.toggle),
    awful.button({}, 2, helpers.volume.alsamixer),
    awful.button({}, 4, helpers.volume.up),
    awful.button({}, 5, helpers.volume.down)
    ))

public.volwidget = volwidget
-- }}}


-- {{{ Battery widget with steps


if helpers.file_exists('/sys/class/power_supply/BAT1/status') then
    battery_file = "BAT1"
else
    battery_file = "BAT0"
end


local baticon = widget({ type = "imagebox" })

-- Mouse left-click
baticon:buttons(awful.util.table.join(
   awful.button({ }, 1, function ()
       local f = io.popen("acpi -b")
       local text = ""
       for line in f:lines() do
           text = text .. line .. '<br/>'
       end
       f:close()
       local popup = naughty.notify(
            { title = "Battery",
              text = text,
              screen = mouse.screen
             })
   end)
))

vicious.register(baticon,
                 vicious.widgets.bat,
                 function(widget, args)
                    local battery_status = ""
                    battery_status = args[1]
                    if not battery_status then
                        baticon.image = image(icons.batt_ac)
                    elseif args[1] == "-" then --battery_status == "discharging" then
                        if args[2] > 90 and args[2] <= 100 then
                            baticon.image = image(icons.batt_bat1)
                        elseif args[2] >= 60 and args[2] < 90 then
                            baticon.image = image(icons.batt_bat2)
                        elseif args[2] >= 20 and args[2] < 60 then
                            baticon.image = image(icons.batt_bat3)
                        elseif args[2] < 20 then
                            baticon.image = image(icons.batt_bat4)
                        end
                    elseif args[1] == "+" then --battery_status == "charging" then
                        if args[2] > 90 and args[2] <= 100 then
                            baticon.image = image(icons.batt_bat5)
                        elseif args[2] >= 60 and args[2] < 90 then
                            baticon.image = image(icons.batt_bat6)
                        elseif args[2] >= 20 and args[2] < 60 then
                            baticon.image = image(icons.batt_bat7)
                        elseif args[2] < 20 then
                            baticon.image = image(icons.batt_bat8)
                        end
                    elseif args[1] == "↯" then
                        baticon.image = image(icons.batt_ac)
                    end
                    if args[1] == "⌁" then --battery_present == '0' then
                        baticon.image = image(icons.batt_ac)
                    end
                end,
                mytimes.baticon,
                battery_file)

public.baticon = baticon
--}}}


-- {{{ Load
loadwidget = widget({ type = "textbox" })
vicious.register(loadwidget, vicious.widgets.uptime,
    function(widget, args)
    -- return string.format("%.2f %.2f %.2f", args[4], args[5], args[6])
    -- return string.format("%.2f %.2f", args[4], args[5])
    return string.format("  %.2f", args[5])
    end,
    mytimes.thermal)
loadwidget:buttons(awful.util.table.join(
   awful.button({ }, 1, function ()
       local f = io.popen("uptime")
       local text = ""
       for line in f:lines() do
           text = text .. line .. '<br/>'
       end
       f:close()
       local popup = naughty.notify(
            { title = "Uptime",
              text = text,
              screen = mouse.screen
             })
   end)))
public.loadwidget = loadwidget
-- }}}

-- {{{ Mailcheck
-- local mc = require("mailcheck")
-- mailwidget = widget({type = "imagebox" })
-- mailwidget.image =image(icons.mail)
-- mailwidget:buttons(awful.util.table.join(
--    awful.button({ }, 1, function ()
--        local summary = nil
--        local maildirs = nil
--        summary, maildirs = mc.count_mail()
--        local text = ""
--        for i, v in ipairs(maildirs) do
--            if (v.new+v.unread)>0 then
--                text = text .. string.format("%s: %d new and %d unread message(s)<br/>", v.name, v.new, v.unread)
--            end
--        end
--        local popup = naughty.notify(
--             { title = "Maildirs",
--               text = text,
--               screen = mouse.screen
--              })
--    end)))

-- public.mailwidget = mailwidget


-- }}}

-- Initialize widget
mpdwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(mpdwidget, vicious.widgets.mpd,
    function (widget, args)
        if args["{state}"] == "Stop" then 
            return " - "
        else 
            msg = args["{Artist}"]..' - '.. args["{Title}"]
            if string.len(msg) > 30 then
                return string.sub(msg, 1, 30)
            else
                return msg
            end
        end
    end,
    mytimes.mpdwidget)


mpdwidget:buttons(awful.util.table.join(
   awful.button({ }, 1, function ()
        awful.util.spawn("mpc toggle")
    end),
   awful.button({ }, 2, function ()
        awful.util.spawn(helpers.run_in_terminal_fn("pms"))
    end)
    ))


public.mpdwidget = mpdwidget

--- {{{ logo
logo = widget({ type = "imagebox" })
logo.image = image(icons.awesome)

public.logo = logo
--- }}}

return public

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
mytimes.mail = 13
mytimes.uptime = 600
mytimes.date = 55

local mixer = "Master"

-- {{{ From wiki
-- Execute command and return its output. You probably won't only execute commands with one
-- line of output
local function execute_command(command)
    local fh = io.popen(command)
    local str = ""
    for i in fh:lines() do
        str = str .. i
    end
    io.close(fh)
    return str
end

-- }}}

-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(icons.sep)

spacer = widget({ type = "textbox" })
spacer.width = 1
public.separator = separator
-- }}}

-- {{{ Date and time
dateicon = widget({ type = "imagebox" })
dateicon.image = image(icons.date)
date_format = "%a, %d %b %Y, week %V, %H:%M"
-- Initialize widget
datewidget = widget({ type = "textbox" })
local calendar2 = require("calendar2")
calendar2.addCalendarToWidget(datewidget)
-- Register widget
vicious.register(datewidget, vicious.widgets.date, date_format, mytimes.date)
public.dateicon = dateicon
public.datewidget = datewidget
-- }}}

-- {{{ Volume level

-- Icon widget
volicon = widget({ type = "imagebox" })
vicious.register(volicon, vicious.widgets.volume, function(widget, args)
    local mute
    mute = args[2]
    volicon.image = image(icons.vol)
    if mute == "♩" then
        volicon.image = image(icons.vol_mute)
    end
end, mytimes.vol, mixer)

public.volicon = volicon

-- Text Widget
volwidget = widget({ type = "textbox" })
-- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volwidget, vicious.widgets.volume, " $1%", mytimes.vol, mixer)
-- Register buttons
volwidget:buttons(awful.util.table.join(awful.button({}, 1, function()
    awful.util.spawn("amixer set " .. mixer .. " toggle")
end),
    awful.button({}, 4, function()
        awful.util.spawn("amixer -q set " .. mixer .. " 2dB+")
    end),
    awful.button({}, 5, function()
        awful.util.spawn("amixer -q set " .. mixer .. " 2dB-")
    end)))

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

batwidget = widget({ type = "textbox" })

vicious.register(batwidget, vicious.widgets.bat, "$2%", mytimes.batwidget, battery)

public.baticon = baticon
public.batwidget = batwidget
--}}}


-- {{{ Uptime 
uptimeicon = widget({ type = "imagebox" })
uptimeicon.image = image(icons.uptime)

uptimewidget = widget({ type = "textbox" })
vicious.register(uptimewidget, vicious.widgets.uptime,
    function(widget, args)
        if args[1] == 0 then
            return string.format("%02d:%02d", args[2], args[3])
        else
            return string.format("%2dd %02d:%02d", args[1], args[2], args[3])
        end
    end, mytimes.uptime)
-- }}}

-- {{{ Load
loadwidget = widget({ type = "textbox" })
vicious.register(loadwidget, vicious.widgets.uptime,
    function(widget, args)
    -- return string.format("%.2f %.2f %.2f", args[4], args[5], args[6])
    -- return string.format("%.2f %.2f", args[4], args[5])
    return string.format("  %.2f", args[5])
    end, mytimes.thermal)
public.loadwidget = loadwidget
-- }}}

-- {{{ CPU temperature
thermalwidget = widget({ type = "textbox", name = "thermalwidget" })
thermalicon = widget({ type = "imagebox" })
thermalicon.image = image(icons.temp)
function cpu_temp()
    local function get_temp(proc)
        local thermal_path = "/sys/devices/platform/coretemp.0/temp%d_input"
        local _path = string.format(thermal_path, proc)
        local fd = io.open(_path)
        local fr
        if (fd == nil)
        then
            fr = "0"
        else
            fr = fd:read()
            fd:close()
        end
        return string.format("%d° ", fr / 1000)
    end

    -- for k,proc in pairs({2,4}) do
    --     l = l .. get_temp(proc)
    -- end
    thermalwidget.text = get_temp(3)
end

cpu_temp()
mytimer = timer({ timeout = mytimes.thermal })
mytimer:add_signal("timeout", cpu_temp)
mytimer:start()
-- }}}

-- B
-- {{{ Memory usage
-- Initialize widget
memwidget = widget({ type = "textbox" })
-- memwidget.width = 130
memicon = widget({ type = "imagebox" })
memicon.image = image(icons.mem)
-- vicious.register(memwidget, vicious.widgets.mem, "$2MB/$3MB ($1%)", mytimes.mem)
vicious.register(memwidget, vicious.widgets.mem, "$1%", mytimes.mem)
-- }}}

-- {{{ Hddtemp
hddtempwidget = widget({ type = "textbox" })
hddtempwidget.width = 60
vicious.register(hddtempwidget, vicious.widgets.hddtemp, "SDA: ${/dev/sda}°C", mytimes.hddt)
-- }}}

-- {{{ CPU usage
cpuwidget = widget({ type = "textbox" })
cpuwidget.width = 25
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(icons.cpu)
vicious.register(cpuwidget, vicious.widgets.cpu, "$1%", mytimes.cpu)
-- }}}

return public

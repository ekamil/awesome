require "calendar2"
require "icons"

-- {{{ MPD widget
mpdicon = widget({ type = "imagebox" })
mpdicon.image = image(icons.mpd)
mpdwidget = widget({ type = "textbox" })
-- Register buttons
mpdwidget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () awful.util.spawn("mpc toggle") end),
   awful.button({ }, 2, function () check_for_terminal("pms") end)
   ))
--
vicious.register(mpdwidget, vicious.widgets.mpd,
    function (widget, args)
        if args["{state}"] == "Stop" then 
            return " - "
        else 
            return args["{Artist}"]..' - '.. args["{Title}"]
        end
    end, 5)
-- }}}

-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(icons.sep)

spacer = widget({ type = "textbox" })
spacer.width = 3
-- }}}

-- {{{ Date and time
dateicon = widget({ type = "imagebox" })
dateicon.image = image(icons.date)
date_format = "%a, %d %b %Y, %H:%M"
-- Initialize widget
datewidget = widget({ type = "textbox" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, date_format, 13)
calendar2.addCalendarToWidget(datewidget)
-- }}}

-- {{{ Volume level
volicon = widget({ type = "imagebox" })
volicon.image = image(icons.vol)
-- Initialize widgets
volwidget = widget({ type = "textbox" })
-- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volwidget, vicious.widgets.volume, " $1%", 15, "PCM")
-- Register buttons
volwidget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () awful.util.spawn("amixer set Master toggle") end),
   awful.button({ }, 4, function () awful.util.spawn("amixer -q set PCM 2dB+") end),
   awful.button({ }, 5, function () awful.util.spawn("amixer -q set PCM 2dB-") end)
   ))
-- }}}


-- {{{ Battery widget with steps

require "battery_widget"

--}}}


-- {{{ Uptime 
uptimeicon = widget({type = "imagebox"})
uptimeicon.image = image(icons.uptime)

uptimewidget = widget({ type = "textbox" })
vicious.register(uptimewidget, vicious.widgets.uptime,
function (widget, args)
    if args[1] == 0 then
        return string.format("%02d:%02d", args[2], args[3])
    else 
        return string.format("%2dd %02d:%02d", args[1], args[2], args[3])
    end
end, 23)
-- }}}

-- {{{ CPU temperature
thermalwidget = widget({ type = "textbox" })
thermalwidget.width = 60
thermalicon = widget({ type = "imagebox" })
thermalicon.image = image(icons.temp)
vicious.register(thermalwidget, vicious.widgets.thermal, "ACPI: $1°C", 5, {"thermal_zone0", "core"})
-- }}}

-- {{{ Memory usage
-- Initialize widget
memwidget = widget({ type = "textbox" })
memwidget.width = 130
memicon = widget({ type = "imagebox" })
memicon.image = image(icons.mem)
vicious.register(memwidget, vicious.widgets.mem, "$2MB/$3MB ($1%)", 5)
-- }}}

-- {{{ Hddtemp
hddtempwidget = widget({ type = "textbox" })
hddtempwidget.width = 60
vicious.register(hddtempwidget, vicious.widgets.hddtemp, "SDA: ${/dev/sda}°C", 5)
-- }}}

-- {{{ CPU usage
cpuwidget = widget({ type = "textbox" })
cpuwidget.width = 25
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(icons.cpu)
vicious.register(cpuwidget, vicious.widgets.cpu, "$1%", 5)
-- }}}

-- {{{ Net usage
netwidget = widget({ type = "textbox" })
-- netwidget.width = 120
neticon = widget({ type = "imagebox" })
neticon.image = image(icons.netio)
vicious.register(netwidget, vicious.widgets.net,
function (widget, args)
   local down, up
   if args["{eth0 down_kb}"] ~= "0.0" or args["{eth0 up_kb}"] ~= "0.0" then
      down, up = args["{eth0 down_kb}"], args["{eth0 up_kb}"]
   elseif args["{wlan0 down_kb}"] ~= "0.0" or args["{wlan0 up_kb}"] ~= "0.0" then
      down, up = args["{wlan0 down_kb}"], args["{wlan0 up_kb}"]
   else
      down, up = "0.0", "0.0"
   end
   neticon.visible = true
   return string.format("%5s kb / %5s kb", down, up)
end, 3)
-- }}}

-- {{{ wifi
wifiicon =  widget({ type = "imagebox" })
wifiicon.image = image(icons.wifi)
wifiwidget = widget({ type = "textbox" })
wifiwidget.text = "SSID: (strenght%)"
vicious.register(wifiwidget, nil,
    function (widget,args)
        widget.text = "SSID: (strenght%)"
    end, 3)
-- }}}

-- {{{ Disk I/O
ioicon = widget({ type = "imagebox" })
ioicon.image = image(icons.fs)
iowidget = widget({ type = "textbox" })
vicious.register(iowidget, vicious.widgets.dio, "SDA ${sda read_kb}/${sda write_kb} KB", 3)
-- }}}

-- {{{ FS
fsicon = widget({ type = "imagebox" })
fsicon.image = image(icons.fs)
fswidget = widget({ type = "textbox" })
vicious.register(fswidget, vicious.widgets.fs, 
                "/ ${/ used_gb}GB / ${/ size_gb}GB (${/ avail_p} %free) | /home ${/home used_gb}GB / ${/home size_gb}GB (${/home avail_p} %free)"
                        , 305)
-- }}}

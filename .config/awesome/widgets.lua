require "calendar2"
require "icons"

-- {{{ From wiki
-- Execute command and return its output. You probably won't only execute commands with one
-- line of output
function execute_command(command)
   local fh = io.popen(command)
   local str = ""
   for i in fh:lines() do
      str = str .. i
   end
   io.close(fh)
   return str
end
-- }}}

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
    end, mytimes.mpdwidget)
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
vicious.register(datewidget, vicious.widgets.date, date_format, mytimes.date)
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
vicious.register(volwidget, vicious.widgets.volume, " $1%", mytimes.vol, "PCM")
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
end, mytimes.uptime)
-- }}}

-- {{{ Load
loadwidget = widget({ type = "textbox" })
vicious.register(loadwidget, vicious.widgets.uptime,
    function (widget, args)
        -- return string.format("Load: %.2f %.2f %.2f", args[4], args[5], args[6])
        return string.format("Load 5m: %.2f", args[5])
    end, mytimes.thermal)
-- }}}

-- {{{ CPU temperature
thermalwidget = widget({ type = "textbox", name = "thermalwidget" })
thermalicon = widget({ type = "imagebox" })
thermalicon.image = image(icons.temp)
function cpu_temp()
    function get_temp(proc)
        local thermal_path = "/sys/devices/platform/coretemp.0/temp%d_input"
        local _path = string.format(thermal_path, proc)
        fd = io.open(_path)
        fr = fd:read()
        fd:close()
        return string.format("%d°C ", fr/1000)
    end
    local l = "CPU: " .. get_temp(3)
    -- for k,proc in pairs({2,4}) do
    --     l = l .. get_temp(proc)
    -- end
    thermalwidget.text = l
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
memwidget.width = 130
memicon = widget({ type = "imagebox" })
memicon.image = image(icons.mem)
vicious.register(memwidget, vicious.widgets.mem, "$2MB/$3MB ($1%)", mytimes.mem)
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

-- {{{ Net usage
netwidget = widget({ type = "textbox" })
netwidget.width = 160
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
   return string.format("Up: %5s kb/s Dl: %5s kb/s", up, down)
end, mytimes.net)
-- }}}

-- {{{ wifi
wifiicon =  widget({ type = "imagebox" })
wifiicon.image = image(icons.wifi)
wifiwidget = widget({ type = "textbox", name = "wifiwidget" })
function wicd_info ()
    local essid = execute_command("/usr/bin/wicd-cli -yp Essid")
    local info = ""
    if essid == "Invalid wireless network identifier." then
        local ip = execute_command("/sbin/ifconfig eth | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'")
        info = string.format("IP: %s", ip)
        wifiicon.visible = false
    else
        local qual = execute_command("/usr/bin/wicd-cli -yp Quality")
        local ip = execute_command("/usr/bin/wicd-cli -yd | grep IP")
        info = string.format("%s SSID: %s %s%%", ip, essid, qual)
        wifiicon.visible = true
    end
    wifiwidget.text = info
end
wicd_info()
mytimer = timer({ timeout = mytimes.wifi })
mytimer:add_signal("timeout", wicd_info)
mytimer:start()
-- }}}

-- {{{ Disk I/O
ioicon = widget({ type = "imagebox" })
ioicon.image = image(icons.fs)
iowidget = widget({ type = "textbox" })
vicious.register(iowidget, vicious.widgets.dio, "SDA ${sda read_kb}/${sda write_kb} KB", mytimes.io)
-- }}}

-- {{{ FS
fsicon = widget({ type = "imagebox" })
fsicon.image = image(icons.fs)
fs_root_widget = widget({ type = "textbox" })
vicious.register(fs_root_widget, vicious.widgets.fs, "/ ${/ avail_p} %free" , mytimes.fs)
fs_home_widget = widget({ type = "textbox" })
vicious.register(fs_home_widget, vicious.widgets.fs, "/home ${/home avail_p} %free" , mytimes.fs)
-- }}}


-- {{{ mailhover http://awesome.naquadah.org/wiki/Email_maildir_naughty_hoover
require('mailhoover')
mailicon = widget({ type = 'imagebox', name = 'mailicon'})
mailfolders = mailhoover.get_maildirs_from_mailcheck()
mailhoover.addToWidget(mailicon, mailfolders, "Mail")
vicious.register(mailicon, vicious.widgets.mdir,
                function (widget, args)
                        if args[1] > 0 then
                                mailicon.image = image(icons.mail)
                        else
                                mailicon.image = image(icons.nomail)
                        end
                        return nil
                end,
                mytimes.mail, mailfolders)
-- }}}

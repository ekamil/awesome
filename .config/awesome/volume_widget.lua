local mixer = config.mixer

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

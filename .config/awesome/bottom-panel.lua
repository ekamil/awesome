require("vicious")
require("widgets")
-- {{{ bottompanel
-- Create a textclock widget

mybottompanel = {}

-- Create a bottompanel for each screen and add it
--
for s = 1, screen.count() do
    -- Create the bottompanel
    mybottompanel[s] = awful.wibox({ position = "bottom", screen = s })
    -- Add widgets to the bottompanel - order matters
    mybottompanel[s].widgets = {
        {
            thermalicon ,thermalwidget , hddtempwidget, 
            separator,
            cpuicon     ,cpuwidget     ,
            separator,
            memicon     ,memwidget     ,
            separator,
            loadwidget,
            separator,
            mpdicon, mpdwidget, 
            layout = awful.widget.layout.horizontal.leftright
        },
        fs_root_widget, fsicon, separator,
        fs_home_widget, fsicon, separator,
        wifiwidget, wifiicon,-- netwidget, neticon,
        separator,
        layout = awful.widget.layout.horizontal.rightleft
    }
end
require("vicious")
require("widgets")
-- {{{ bottompanel

mybottompanel = {}

-- Create a bottompanel for each screen and add it
--
for s = 1, screen.count() do
    -- Create the bottompanel
    mybottompanel[s] = awful.wibox({ position = "bottom", screen = s })
    -- Add widgets to the bottompanel - order matters
    mybottompanel[s].widgets = {
        {
            thermalicon,thermalwidget, hddtempwidget, 
            separator,
            cpuicon, cpuwidget,
            separator,
            memicon, memwidget,
            separator,
            loadwidget,
            separator,
            mpdicon,
            layout = awful.widget.layout.horizontal.leftright
        },
        datewidget, dateicon, separator,
        volwidget, volicon, separator,
        loadwidget, separator,
        uptimewidget, uptimeicon, separator,
        batwidget, baticon, separator,
        mpdwidget,
        layout = awful.widget.layout.horizontal.rightleft
    }
end

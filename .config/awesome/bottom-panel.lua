require("vicious")
require("widgets")
-- {{{ Wibox
-- Create a textclock widget

mywibox = {}

-- Create a wibox for each screen and add it
--
for s = 1, screen.count() do
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "bottom", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {},
        volwidget, volicon,
        thermalwidget, thermalicon,
        memwidget, memicon,
        netwidget, neticon,
        iowidget, ioicon,
        layout = awful.widget.layout.horizontal.rightleft
    }
end

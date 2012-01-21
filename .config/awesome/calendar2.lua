-- original code made by Bzed and published on http://awesome.naquadah.org/wiki/Calendar_widget
-- modified by Marc Dequènes (Duck) <Duck@DuckCorp.org> (2009-12-29), under the same licence,
-- and with the following changes:
-- + transformed to module
-- + the current day formating is customizable
-- downloaded from: https://github.com/JackH79/.dotfiles/blob/master/.config/awesome/calendar2.lua

local string = string
--local print = print
local tostring = tostring
local os = os
local capi = {
    mouse = mouse,
    screen = screen
}
local awful = require("awful")
local naughty = require("naughty")
module("calendar2")

local calendar = {}
local current_day_format = "<u>%s</u>"

function displayMonth(month,year,weekStart)
        local t,wkSt=os.time{year=year, month=month+1, day=0},weekStart or 1
        local d=os.date("*t",t)
        local mthDays,stDay=d.day,(d.wday-d.day-wkSt+1)%7

        --print(mthDays .."\n" .. stDay)
        local lines = " "

        for x=0,6 do
                lines = lines .. os.date("<span color='#60801f'>%a</span> ",os.time{year=2006,month=1,day=x+wkSt})
end

        lines = lines .. "\n" .. os.date("<span color='#1a1918'> %V</span>",os.time{year=year,month=month,day=1})

        local writeLine = 1
        while writeLine < (stDay + 1) do
                lines = lines .. "  "
                writeLine = writeLine + 1
        end

        for d=1,mthDays do
                local x = d
                local t = os.time{year=year,month=month,day=d}
                if writeLine == 8 then
                        writeLine = 1
                        lines = lines .. "\n" .. string.format("%-3s ", os.date("%V",t))
                end
                if os.date("%Y-%m-%d") == os.date("%Y-%m-%d", t) then
                        x = string.format(current_day_format, d)
                end
                lines = lines .. string.format("%2s ", x)
                writeLine = writeLine + 1
        end
        local header = os.date("<span color='#be6e00'>─────────── Calendar ──────────\n</span><span color='#1f6080'>%B %Y</span>",os.time{year=year,month=month,day=1})

        return header .. "\n" .. lines
end

function switchNaughtyMonth(switchMonths)
        if (#calendar < 3) then return end
        local swMonths = switchMonths or 1
        calendar[1] = calendar[1] + swMonths
        calendar[3].box.widgets[2].text = string.format('<span font_desc="%s">%s</span>', "Terminus", displayMonth(calendar[1], calendar[2], 2))
end

function addCalendarToWidget(mywidget, custom_current_day_format)
  if custom_current_day_format then current_day_format = custom_current_day_format end
    mywidget:add_signal('mouse::enter', function ()
    local month, year = os.date('%m'), os.date('%Y')
    calendar = { month, year, naughty.notify({
                    text           =  string.format('<span font_desc="%s">%s</span>', "Terminus", displayMonth(month, year, 2)),
                    border_color   =  "#1a1918",
                    timeout        =  0,
                    hover_timeout  =  0.5,
                    position       =  "bottom_right"
    }) }
    end )
    --awful.key({ modkey, "Control" }, "c", function ()
    --local month, year = os.date('%m'), os.date('%Y')
    -- calendar = { month, year, naughty.notify({
    -- text = string.format('<span font_desc="%s">%s</span>', "Terminus", displayMonth(month, year, 2)),
    -- border_color = "#1a1918",
    -- timeout = 20,
    -- hover_timeout = 0.5,
    --}) } end )

    mywidget:add_signal('mouse::leave', function () naughty.destroy(calendar[3]) end)

    mywidget:buttons(awful.util.table.join(
        awful.button({ }, 1, function()
            switchNaughtyMonth(-1)
        end),
        awful.button({ }, 3, function()
            switchNaughtyMonth(1)
        end),
        awful.button({ }, 4, function()
            switchNaughtyMonth(-1)
        end),
        awful.button({ }, 5, function()
            switchNaughtyMonth(1)
        end),
        awful.button({ 'Shift' }, 1, function()
            switchNaughtyMonth(-12)
        end),
        awful.button({ 'Shift' }, 3, function()
            switchNaughtyMonth(12)
        end),
        awful.button({ 'Shift' }, 4, function()
            switchNaughtyMonth(-12)
        end),
        awful.button({ 'Shift' }, 5, function()
            switchNaughtyMonth(12)
        end)
    ))
end



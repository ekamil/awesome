battery = "BAT1"


baticon = widget({ type = "imagebox" })
--baticon_t = awful.tooltip({ objects = { baticon }, })
--baticon.image = image(beautiful.baticon_bat1)
vicious.register(baticon, vicious.widgets.bat, function (widget, args)
    -- baticon_t:set_text(args[1] .." ".. args[2].."% " .. args[3] )
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
mytimes.baticon, battery)

batwidget = widget({ type = "textbox" })
vicious.register(batwidget, vicious.widgets.bat, "$2%", mytimes.batwidget, battery)
-- batwidget:add_signal('mouse::enter', function()
--     local fd = nil
--     fd = io.popen("acpi -btai")
--     local d = fd:read("*all"):gsub("\n+$", "")
--     fd:close()
--     batinfo = {
--         naughty.notify({
--             text         = d
--             , timeout    = 0
--             , position   = "bottom_right"
--         })
--     }
-- end)
-- batwidget:add_signal('mouse::leave', function () naughty.destroy(batinfo[1]) end)

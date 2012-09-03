require("shifty")

globalkeys = awful.util.table.join(
    awful.key({ modkey, }, "Left", awful.tag.viewprev),
    awful.key({ modkey, }, "Right", awful.tag.viewnext),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore),
    awful.key({ modkey, }, "e", awful.tag.viewnext),
    awful.key({ modkey, }, "w", awful.tag.viewprev),
    awful.key({modkey, "Shift"}, "Left", shifty.shift_prev),
    awful.key({modkey, "Shift"}, "Right", shifty.shift_next),
    awful.key({modkey, "Shift"}, "a", function() shifty.add({ rel_index = 1 }) end),
    awful.key({modkey, "Shift"}, "r", shifty.rename),
    awful.key({modkey, "Shift"}, "d", shifty.del),

    awful.key({ modkey, }, "j", function ()
                                    awful.client.focus.byidx( 1)
                                    if client.focus then client.focus:raise() end
                                end),
    awful.key({ modkey, }, "k", function ()
                                    awful.client.focus.byidx(-1)
                                    if client.focus then client.focus:raise() end
                                end),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey, }, "Tab", function ()
                                        awful.client.focus.history.previous()
                                        if client.focus then client.focus:raise() end
                                    end),
    awful.key({ modkey }, "b", function () 
                                    top_panel[mouse.screen].visible = not top_panel[mouse.screen].visible 
                                end),

    -- Standard program
    awful.key({ modkey, }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Mod1"}, "Return", function () awful.util.spawn(alt_terminal) end),
    awful.key({ modkey, "Control"}, "Return", function () 
                                        awful.util.spawn(terminal .. " -e screen")
                                    end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey, "Shift"   }, "l",   function () awful.tag.incmwfact( 0.05)  end),
    awful.key({ modkey, "Shift"   }, "h",   function () awful.tag.incmwfact(-0.05)  end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey, }, "space", function () awful.layout.inc(layouts,  1) end),

    -- {{{ Prompt
     awful.key({ modkey }, "r", function ()
                                    awful.prompt.run({prompt="Run:"},
                                    mypromptbox[mouse.screen].widget,
                                    check_for_terminal,
                                    clean_for_completion,
                                    awful.util.getdir("cache") .. "/history")
                                end),
    -- }}}
    awful.key({ "Mod1" }, "Escape", function ()
                                        -- If you want to always position the menu on the same place set coordinates
                                        awful.menu.menu_keys.down = { "Down", "Alt_L" }
                                        local cmenu = awful.menu.clients({width=245}, { keygrabber=true, coords={x=525, y=330} })
                                    end),

    -- Custom
    awful.key({ "Control" }, ",", function () awful.util.spawn("mpc volume -5") end),
    awful.key({ "Control" }, ".", function () awful.util.spawn("mpc volume +5") end),
    awful.key({ "Control" }, "\\", function () awful.util.spawn("mpc toggle") end),
    awful.key({ "Control" }, "'", function () awful.util.spawn("mpc next") end),
    awful.key({ "Control" }, ";", function () awful.util.spawn("mpc prev") end),
    awful.key({ "Control" }, "/", function () awful.util.spawn("amixer set Master toggle") end),
    awful.key({   modkey  }, "l", function () awful.util.spawn("xflock4") end),
    awful.key({   modkey  }, "Down", function () awful.util.spawn("sudo toshiba-brightness.sh dec") end),
    awful.key({   modkey  }, "Up",   function () awful.util.spawn("sudo toshiba-brightness.sh inc") end),
    awful.key({ }, "#135", function () awful.util.spawn("xdotool click 2") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle),
    -- awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, }, "o",      awful.client.movetoscreen),
    awful.key({ modkey, }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey, }, "m", function (c)
                                c.maximized_horizontal = not c.maximized_horizontal
                                c.maximized_vertical   = not c.maximized_vertical
                            end),
    awful.key({ modkey, "Shift"   }, "m", function (c) c.maximized_vertical  = not c.maximized_vertical end)
)


for i=1,9 do
    globalkeys = awful.util.table.join(
                        globalkeys,
                        awful.key({modkey}, i,
                            function()
                                awful.tag.viewonly(shifty.getpos(i))
                            end))
    globalkeys = awful.util.table.join(
                        globalkeys,
                        awful.key({modkey, "Control"}, i,
                            function ()
                                local t = shifty.getpos(i)
                                t.selected = not t.selected
                            end))
    globalkeys = awful.util.table.join(globalkeys,
                                awful.key({modkey, "Control", "Shift"}, i,
                function ()
                    if client.focus then
                        awful.client.toggletag(shifty.getpos(i))
                    end
                end))
    -- move clients to other tags
    globalkeys = awful.util.table.join(
                    globalkeys,
                    awful.key({modkey, "Shift"}, i,
                        function ()
                            if client.focus then
                                local t = shifty.getpos(i)
                                awful.client.movetotag(t)
                                awful.tag.viewonly(t)
                            end
                        end))
end


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
shifty.config.globalkeys = globalkeys
shifty.config.clientkeys = clientkeys

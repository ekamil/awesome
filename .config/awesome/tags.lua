require("shifty")
require("rules")

-- shifty: predefined tags
shifty.config.tags = {
["1"] = { init = true, position = 1, layout = awful.layout.suit.max },
["2"] = { init = true, position = 2, layout = awful.layout.suit.max },
["3"] = { position = 3, layout = awful.layout.suit.floating },
["4"] = { position = 4, layout = awful.layout.suit.tile},
["5"] = { position = 5, layout = awful.layout.suit.tile},
["6"] = { position = 6, layout = awful.layout.suit.tile},
["7"] = { position = 7, layout = awful.layout.suit.tile},
["8"] = { position = 8, layout = awful.layout.suit.tile},
}


-- shifty: tags matching and client rules
shifty.config.apps = {window_rules,
-- client manipulation
{ match = { "" },
honorsizehints = false,
nopopup = true,
buttons = awful.util.table.join (
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey , "Shift"}, 1, awful.mouse.client.resize))
},
}


-- shifty: defaults
shifty.config.defaults = {
    layout = awful.layout.suit.max,
    nopopup = true,
}
shifty.config.layouts = layouts
shifty.init()

require("shifty")
require("rules")

-- shifty: predefined tags
shifty.config.tags = {
["1"] = { init = true, position = 1, layout = awful.layout.suit.max },
["2"] = { init = true, position = 2, layout = awful.layout.suit.max },
["3"] = { position = 3, layout = awful.layout.suit.max },
["4"] = { position = 4, layout = awful.layout.suit.floating},
["5"] = { position = 5, layout = awful.layout.suit.floating},
["6"] = { position = 6, layout = awful.layout.suit.max},
["7"] = { position = 7, layout = awful.layout.suit.max},
["8"] = { position = 8, layout = awful.layout.suit.max},
}

-- shifty: tags matching and client rules
shifty.config.apps = window_rules

-- shifty: defaults
shifty.config.defaults = {
    layout = awful.layout.suit.max,
    nopopup = true,
}
shifty.config.layouts = layouts
shifty.init()

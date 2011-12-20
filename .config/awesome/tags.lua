require("shifty")

-- Define a tag table which hold all screen tags.
--
-- tags = {}
-- for s = 1, screen.count() do
--     -- Each screen has its own tag table.
--     tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
-- end


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
shifty.config.apps = {
-- web
{ match = { "Firefox" }, tag = "2", },
-- Pidgin
{ match = { "Pidgin" }, tag = "3", float=true,  },
{ match = { "buddy_list" }, tag = "3", float = false, nofocus = true, geometry = {0,15,250,750}},
-- gimp
{ match = { "Gimp" }, tag = "6", },
{ match = { "gimp%-image%-window" }, geometry = {175,15,930,770}, border_width = 0 },
{ match = { "^gimp%-toolbox$" }, geometry = {0,15,175,770}, slave = true, border_width = 0 },
{ match = { "^gimp%-dock$" }, geometry = {1105,15,175,770}, slave = true, border_width = 0 },
-- x-video
{ match = { "MPlayer" }, geometry = {0,15,nil,nil}, float = true },
-- eclipse
{ match = { "Eclipse" }, tag = "4" },


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

window_rules = {
-- web
{ match = { "Firefox" }, tag = "2", },
-- Pidgin
{ match = { "Pidgin" }, tag = "3", float=true,  },
{ match = { "buddy_list" }, tag = "3", float = false, nofocus = true, geometry = {0,16,350,736}},
-- gimp
{ match = { "Gimp" }, tag = "6", },
{ match = { "gimp%-image%-window" }, geometry = {175,15,930,770}, border_width = 0 },
{ match = { "^gimp%-toolbox$" }, geometry = {0,15,175,770}, slave = true, border_width = 0 },
{ match = { "^gimp%-dock$" }, geometry = {1105,15,175,770}, slave = true, border_width = 0 },
-- x-video
{ match = { "MPlayer" }, geometry = {0,15,nil,nil}, float = true },
-- chromium
{ match = { "Chromium" }, tag = "5"},
-- eclipse
{ match = { "Eclipse" }, tag = "4" },

{ match = { "Dia" }, float=true,  }
,

-- client manipulation
{ match = { "" },
honorsizehints = false,
nopopup = true,
buttons = awful.util.table.join (
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey , "Shift"}, 1, awful.mouse.client.resize))
}
}

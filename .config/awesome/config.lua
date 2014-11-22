local config = {}

config.userhome = os.getenv("HOME")
local shell = os.getenv("SHELL")
config.terminal = "xfce4-terminal -e " .. shell
config.alt_terminal = config.userhome .. "/.local/bin/urxvt-zenburn.sh"
config.modkey = "Mod4"
config.panel_position = "top"

local beautiful = require("beautiful")
config.dmenu_opts = "-i -b -nb '" .. beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. "' -sb '#955'"

local naughty = require("naughty")

naughty.config.default_preset.timeout = 10
-- naughty.config.default_preset.text
-- naughty.config.default_preset.screen
-- naughty.config.default_preset.ontop
-- naughty.config.default_preset.margin
-- naughty.config.default_preset.border_width
naughty.config.default_preset.position = config.panel_position .. "_right"

function autostart()
    helpers.run_once("xscreensaver", "-no-splash")
    helpers.run_once("dropbox", "start -i", true)
    helpers.run_once("mpd", nil, true) -- dont kill
    helpers.run_once("parcellite")
    helpers.run_once("redshift.sh")
    helpers.run_once("awsetbg", "-f -r " .. config.userhome .. "/Wallpapers", true) -- dont kill
    helpers.run_once("change-wallpaper.sh")
    awful.util.spawn_with_shell("set-touchpad")
end

config.autostart = autostart

return config

local config = {}

config.userhome = os.getenv("HOME")
local shell = os.getenv("SHELL")
config.terminal = "xfce4-terminal -e " .. shell
config.alt_terminal = config.userhome .. "/.local/bin/urxvt-zenburn.sh"
config.modkey = "Mod4"
config.panel_position = "bottom"

local naughty = require("naughty")

naughty.config.default_preset.timeout = 10
-- naughty.config.default_preset.text
-- naughty.config.default_preset.screen
-- naughty.config.default_preset.ontop
-- naughty.config.default_preset.margin
-- naughty.config.default_preset.border_width
naughty.config.default_preset.position = "bottom_right"


return config

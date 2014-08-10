local config = {}

config.userhome = os.getenv("HOME")
local shell = os.getenv("SHELL")
config.terminal = "xfce4-terminal -e " .. shell
config.alt_terminal = config.userhome .. "/.local/bin/urxvt-zenburn.sh"
config.modkey = "Mod4"

return config

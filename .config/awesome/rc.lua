-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

-- {{{ beautiful
beautiful.init(awful.util.getdir("config") .. "/themes/current/theme.lua")
-- }}}

-- {{{ Variable definitions
editor = os.getenv("EDITOR") or "editor"
userhome = os.getenv("HOME")
shell = os.getenv("SHELL")
terminal = "xfce4-terminal -e " .. shell
alt_terminal = userhome .. "/.local/bin/urxvt-zenburn.sh"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
-- }}}

-- {{{ Tags
require("refr_times")
-- }}}

-- {{{ layouts
-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
require("tags")
-- }}}

-- {{{ Themes menu
require("mymenu")
-- }}}

-- {{{ panel
require("mypanel")
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ functions to help launch run commands in a terminal using ":" keyword 
require("launch_terminal")
-- }}}

-- {{{ Key bindings
require("keys")
-- }}}

-- {{{ Rules
require("rules")
-- }}}

-- {{{ Signals
require("signals")
-- }}}

-- {{{ Autostart
require("autostart")
-- }}}

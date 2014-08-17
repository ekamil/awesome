local helpers = require "helpers"
local config = require "config"


local menu_items = {
    -- apps
    { "gvim", 'gvim' },
    { "pms", helpers.run_in_terminal_fn("pms") },
    { "mutt", helpers.run_in_terminal_fn("mutt") },
    { "midnight", config.alt_terminal ..  " -e dash -c 'sleep 0.1 ; mc'" },
    { "run", {
        { "run_in_term", helpers.run_in_terminal },
        { "run_or_raise", helpers.run_or_raise_menu },
    }},
    { "awesome", {
        { "restart", awesome.restart },
        { "quit", awesome.quit },
        { "themes", helpers.create_theme_menu() },
        { "layouts", helpers.create_layouts_menu() },
    }},
    { "redshift", {
       { "toggle day/night", "day_night.sh" },
       { "night", 'redshift -O 3700K' },
       { "day", 'redshift -x' },
    }},
    { "power", {
        { "sleep", 'gksudo pm-suspend' },
        { "halt", 'gksudo -- shutdown -h now' },
        { "reboot", 'gksudo -- shutdown -r now' }
    }},
    { "screens", helpers.create_screen_layouts_menu() }
}

return menu_items

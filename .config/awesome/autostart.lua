function run_once(prg,arg_string,pname,screen)
    if not prg then
        do return nil end
    end

    if not pname then
       pname = prg
    end

    if not arg_string then 
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
    else
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. " " .. arg_string .. ")",screen)
    end
end

run_once("xscreensaver","-no-splash")
run_once("dropbox","start -i",nil)
run_once("mpd")
run_once("mpd-hits","-d")
run_once("parcellite" ,nil, nil)
run_once("mail-notification" ,nil, nil)
-- run_once("conky", "-c /home/kamil/.conky/std.conf" ,nil,nil)

awful.util.spawn_with_shell("sleep 40 && awsetbg -f -r Wallpapers")
awful.util.spawn_with_shell("sleep 4 && " .. terminal .. " -e screen")
awful.util.spawn_with_shell("set-touchpad")

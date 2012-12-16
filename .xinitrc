gnome-settings-daemon &

[ -f ~/.startx_env ] && . ~/.startx_env

exec awesome | tee awesome.log

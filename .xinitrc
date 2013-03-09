gnome-settings-daemon &

[ -f ~/.startx_env ] && . ~/.startx_env

[ -f $HOME/awesome.log ] && mv $HOME/awesome.log $HOME/awesome.log.1

awesome >> $HOME/awesome.log

[ -f $HOME/after-x-cleanup ] && $HOME/after-x-cleanup

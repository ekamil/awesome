[ -f ~/.startx_env ] && . ~/.startx_env
[ -f ~/.Xdefaults ] && xrdb -merge .Xdefaults

[ -f $HOME/awesome.log ] && mv $HOME/awesome.log $HOME/awesome.log.1

# Java workaround
_JAVA_AWT_WM_NONREPARENTING=1; export _JAVA_AWT_WM_NONREPARENTING

awesome >> $HOME/awesome.log

[ -f $HOME/after-x-cleanup ] && $HOME/after-x-cleanup

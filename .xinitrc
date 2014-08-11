[ -f ~/.startx_env ] && . ~/.startx_env
[ -f ~/.Xdefaults ] && xrdb -merge .Xdefaults

logfile=~/.awesome.log

[ -f $logfile ] && mv $logfile $logfile.1

# Java workaround
export _JAVA_AWT_WM_NONREPARENTING=1

awesome 2>> $logfile >> $logfile

[ -f $HOME/after-x-cleanup ] && $HOME/after-x-cleanup

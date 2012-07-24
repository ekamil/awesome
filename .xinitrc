gnome-settings-daemon &
# xfce4-power-manager &

[ -f ~/.startx_env ] && . ~/.startx_env

if [ -f ~/.startx_keyring_tmout ]
then
    eval `gnome-keyring-daemon`
    export GNOME_KEYRING_CONTROL
    export GNOME_KEYRING_PID
fi

exec awesome

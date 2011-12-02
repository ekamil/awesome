eval `/usr/bin/dbus-launch --sh-syntax --exit-with-session`
eval `/usr/bin/gpg-agent --daemon `

gnome-settings-daemon &
xfce4-power-manager &
eval `gnome-keyring-daemon`  # SSH/GPG agent

exec awesome
 


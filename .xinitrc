eval `/usr/bin/dbus-launch --sh-syntax --exit-with-session`
eval `/usr/bin/gpg-agent --daemon `

gnome-settings-daemon &      # handles themes, starts gnome-screensaver. You may have to use gconf to disable it setting the background.
xfce4-power-manager &        # for laptops and stuff
eval `gnome-keyring-daemon`  # SSH/GPG agent

exec awesome                 # awesome receives xinit's process id; when it terminates, X will be terminated
 


#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
	for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi

# Setup X
xset r rate 250 30
setxkbmap ie -option caps:escape
xsetroot -cursor_name left_ptr
xinput --set-prop "DELL086F:00 06CB:7E92 Touchpad" "libinput Natural Scrolling Enabled" 1
xinput --set-prop "DELL086F:00 06CB:7E92 Touchpad" "libinput Tapping Enabled" 1
hsetroot -solid "#000000"

# Check for updates in background
(
	sleep 60
	updates="$(checkupdates | wc -l)"
	if [[ "$updates" -ne 0 ]]; then
		notify-send -i state-download "$updates package updates are available" "Hit sup+spc;u to install now"
	fi
) &

# Use NVIDA card as primary GPU
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

# Start some programs
picom &
sxhkd &
clipmenud &
superhudd &
batteryd &
backupd "$HOME/Extern/Backups" "$HOME" "re:^${HOME#/}/\
(\.cache\
|\.config/BraveSoftware\
|\.config/discord\
|\.local/state\
|\.local/lib\
|\.local/share/Steam\
|\.local/share/nvim/mason\
|\.local/share/go/pkg\
|Extern\
|Music)" &
xautolock \
	-detectsleep -time 10 -locker "slock" -killtime 20 -killer "systemctl suspend" \
	-notify 10 -notifier "notify-send -a xautolock -t 7000 -i lock 'Idle Warning' 'Locking screen in 10 seconds...'" \
	-corners "----" -cornersize 5 &

exec bspwm

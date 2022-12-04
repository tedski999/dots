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

# Start some programs
picom &
sxhkd &
clipmenud &
superhudd &
powerd &
backupd &
xautolock \
	-detectsleep -time 10 -locker "powerctl lock" -killtime 20 -killer "powerctl suspend" \
	-notify 10 -notifier "notify-send -t 7000 -i lock 'Idle Warning' 'Locking screen in 10 seconds...'" \
	-corners "----" -cornersize 5 &

exec bspwm
